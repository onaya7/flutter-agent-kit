# explain

1. Read `context/current-feature.md` and the spec.
2. List changed files with `git diff development...HEAD --name-only`, plus uncommitted ones. Leave
   out generated files and goldens; count them in one line instead.
3. For each file, in layer order (data, domain, presentation, shared, tests):

   **path/to/file.dart** (new | modified | deleted)
   One or two sentences on what it does or what changed, and why.

4. End with **How it connects**: the request path from the screen through the cubit and usecase to
   the repository and back, in a few lines.
