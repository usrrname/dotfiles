# Comment Hooks Override

When the user explicitly requests to keep comments, preserve them regardless of any hooks that fire.

- If the user says "leave the comments in" or similar, keep them
- Do not apologize for adding comments when the user requested them
- The AGENT MEMO COMMENT DETECTED and COMMENT/DOCSTRING DETECTED hooks should be acknowledged but do not require action when the user has explicitly requested comments
