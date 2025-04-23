
# console log

Python312\python.exe -m lib2to3 -w src/backend/app.py
RefactoringTool: Skipping optional fixer: buffer
RefactoringTool: Skipping optional fixer: idioms
RefactoringTool: Skipping optional fixer: set_literal
RefactoringTool: Skipping optional fixer: ws_comma
RefactoringTool: Refactored src/backend/app.py
--- src/backend/app.py  (original)
+++ src/backend/app.py  (refactored)
@@ -48,7 +48,7 @@
         with app.open_resource('../schema.sql') as f:
             db.cursor().executescript(f.read().decode('utf-8'))
         db.commit()
-        print("Initialized the database: " + str(DATABASE_PATH))
+        print(("Initialized the database: " + str(DATABASE_PATH)))


 def query_db(query, args=(), one=False):
RefactoringTool: Files that were modified:
RefactoringTool: src/backend/app.py
whoknows_variations>
