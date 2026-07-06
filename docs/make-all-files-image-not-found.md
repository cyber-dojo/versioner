# `make all_files` fails: creator image "not found" on dockerhub

## Symptom

```
make all_files
...
Error response from daemon: failed to resolve reference
"docker.io/cyberdojo/creator:6ff6b4c": docker.io/cyberdojo/creator:6ff6b4c: not found
```

(The failing service may be any of the services, not just `creator`.)

## The problem

`make all_files` runs `make json_files`, which:

1. Takes a **fresh live snapshot** of the `aws-prod` Kosli environment
   (`kosli get snapshot aws-prod ...` in `bin/make_json_files.sh`).
2. For each service, does `docker pull cyberdojo/<service>:<tag>`, where `<tag>`
   is the first 7 chars of the git commit that snapshot reports as currently
   running.

If the snapshot reports a version whose image was never pushed to dockerhub,
the pull 404s.

Confirmed facts from the incident:

- Live snapshot: `creator = 6ff6b4c` (annotation `started-compliant`); older
  `c174ef2` = `exited`.
- dockerhub: `cyberdojo/creator:6ff6b4c` -> NOT FOUND; `2a3119f` -> exists
  (an even older one).
- The copy workflow run (28655780105) **succeeded**, but its log shows it copied
  `creator:c174ef2` to dockerhub at 10:52 - not `6ff6b4c`.

So the image tag that `json_files` wanted was never pushed to dockerhub, even
though the copy workflow reported success.

## The cause

**A new creator version was deployed to `aws-prod` in the ~5-minute gap between
the copy workflow running and the `make all_files` run. The two steps each take
their own independent snapshot, so they disagreed.**

Timeline:

1. **10:52:24** - the copy workflow (`copy_prod_images_to_dockerhub`) took its
   snapshot. At that moment aws-prod's live creator artifact was `c174ef2`
   (`sha256:8130ae29...`). The log shows it pulled that digest from ECR and
   pushed `cyberdojo/creator:c174ef2` to dockerhub. The workflow succeeded -
   correctly, for the state it saw.
2. **Sometime after 10:52** - creator was redeployed in aws-prod to `6ff6b4c`.
   That is why the current snapshot shows `6ff6b4c` as `started-compliant` and
   `c174ef2` demoted to `exited`.
3. **~10:57** - `make all_files` ran. `make json_files` took a fresh snapshot,
   saw `6ff6b4c` as the live creator, and tried `docker pull
   cyberdojo/creator:6ff6b4c`. That tag was never pushed (the copy ran before
   the deploy existed), so it 404s.

Root design hazard: `bin/copy_prod_images_to_dockerhub.sh` and
`bin/make_json_files.sh` **each call `kosli get snapshot aws-prod` separately**,
at different times. They are only consistent if aws-prod does not change between
them. A creator deploy landed in the window, so `json_files` referenced an image
the copy step never had a chance to publish.

Note this is transient: the copy step is not broken; the live environment moved
on after the copy ran.

## Possible fixes

The governing constraint: **the copy step and the json_files step must see the
same snapshot of aws-prod.** Any fix either makes that true, or accepts the race
and retries into a quiet window.

### Fix 1 - One snapshot, shared by both steps (recommended)

Take `kosli get snapshot aws-prod` exactly once, persist the JSON (a file
locally, a workflow artifact in CI), and have both
`copy_prod_images_to_dockerhub.sh` and `make_json_files.sh` read that captured
file instead of each calling the live API. Eliminates the race at its root.
Requires threading a snapshot path through both scripts and the CI jobs.

Preserves the current separation: json generation stays credential-free and
pulls only public dockerhub images; copy stays the privileged CI-only step.

### Fix 2 - Merge copy + generate into a single script/job

One script: snapshot once -> copy all images to dockerhub -> generate json files
from the same artifact list. Simplest to reason about (no shared-file plumbing)
and impossible to diverge, since there is only ever one snapshot. Downside:
couples the two operations, and json generation then always requires the CI
credentials the copy needs (today `make json_files` is credential-free).

### Fix 3 - Make `json_files` self-heal on a 404

If `docker pull cyberdojo/<svc>:<tag>` fails, copy that one image from ECR on the
fly then retry. But `json_files` deliberately has no ECR credentials (it only
touches public dockerhub); giving it creds defeats that separation. This
effectively collapses into Fix 2, so not worth pursuing independently.

### Recommendation

Implement **Fix 1** as the durable change - it removes the race while preserving
the credential separation between the two steps.
