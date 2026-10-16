# handoff

Run before a session ends with the feature unfinished, or when the user asks. A fresh session must
be able to continue from the spec alone.

1. Append a block to the spec's **Progress** section:
   ```markdown
   ### <YYYY-MM-DD> — <phases done this session>
   - Built: phases and the main files, with the gate result (analyze, test count, goldens)
   - Committed: yes with the short SHA, or "nothing committed"
   - Decided: choices made on the user's behalf, so they can be reversed
   - Gotchas: what cost time and will again
   - Next: the first concrete step for the next session
   ```
2. Update **Open questions**: add new ones, mark answered ones with the answer and date.
3. Move any constraint every future session needs into `context/current-feature.md` Notes.
4. Reply with a one-paragraph prompt the user can paste to resume, naming the spec path.
