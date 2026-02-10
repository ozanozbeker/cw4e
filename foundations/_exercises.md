# Foundations Module Question Bank

This document contains 50 questions (10 per chapter) for auto-graded assessment. Questions are designed for LMS compatibility using multiple choice, true/false, and matching formats. Correct answers are marked with **[CORRECT]**.

---

## Chapter 1: Computer Fundamentals

### Question 1.1
What is the primary difference between a **program** and an **application**?

A) Programs run faster than applications
B) Applications are designed for end-user interaction with thoughtful interfaces **[CORRECT]**
C) Programs can only run on servers
D) Applications cannot be run from the command line

### Question 1.2
Which of the following is TRUE about RAM (memory)?

A) RAM retains data when the computer is powered off
B) RAM is slower to access than disk storage
C) RAM is where programs run and files are actively edited **[CORRECT]**
D) RAM typically has more capacity than disk storage

### Question 1.3
Why does loading a large file feel slow?

A) The CPU cannot process the file fast enough
B) The file must be copied from disk into RAM before work can begin **[CORRECT]**
C) Large files are always compressed and need decompression
D) The operating system limits file access speed

### Question 1.4
What happens to unsaved changes in a text editor if your computer loses power?

A) They are automatically recovered from the cloud
B) They are saved to a temporary backup file
C) They are lost because they only existed in volatile RAM **[CORRECT]**
D) They are stored in the CPU cache

### Question 1.5
Why can't you write code in Microsoft Word?

A) Word doesn't support typing special characters
B) Word embeds hidden formatting codes that confuse programming languages **[CORRECT]**
C) Word files are too large for code
D) Word cannot save files with .py extensions

### Question 1.6
What does "volatile" mean when describing computer memory?

A) The memory is dangerous and may cause fires
B) The memory contents are lost when power is removed **[CORRECT]**
C) The memory cannot store large files
D) The memory changes unpredictably during use

### Question 1.7
Which statement about package managers is TRUE?

A) Package managers only work on Linux systems
B) Package managers automatically handle dependencies when installing software **[CORRECT]**
C) Package managers require an internet connection for all operations
D) Package managers replace the need for text editors

### Question 1.8
A **script** is best described as:

A) A compiled program that runs directly on hardware
B) A program written in an interpreted language like Python **[CORRECT]**
C) A graphical application with a user interface
D) A document containing formatting instructions

### Question 1.9
What does syntax highlighting in a text editor do?

A) Automatically corrects spelling errors in code
B) Colors different parts of code based on their grammatical role **[CORRECT]**
C) Highlights lines that contain errors
D) Makes all text the same color for consistency

### Question 1.10
True or False: Closing a program frees the RAM that program was using.

A) True **[CORRECT]**
B) False

---

## Chapter 2: Files and the File System

### Question 2.1
Which of the following is a **text file** that can be opened and read in any text editor?

A) .xlsx (Excel spreadsheet)
B) .jpg (image file)
C) .csv (comma-separated values) **[CORRECT]**
D) .pdf (portable document format)

### Question 2.2
What does an **absolute path** specify?

A) A location relative to the current directory
B) A location starting from the root of the file system **[CORRECT]**
C) A location relative to the home directory
D) A location that changes based on the operating system

### Question 2.3
Which character is used to separate directories in a path?

A) Caret `>`
B) Forward slash `/` (macOS/Linux) or  Backslash `\` (Windows) **[CORRECT]**
C) Colon `:`
D) Period `.`

### Question 2.4
What does the symbol `~` represent in a file path?

A) The root directory
B) The current directory
C) The home directory **[CORRECT]**
D) The parent directory

### Question 2.5
What does the symbol `..` represent in a file path?

A) The root directory
B) The current directory
C) The home directory
D) The parent directory (one level up) **[CORRECT]**

### Question 2.6
Why are hidden files (those starting with `.`) hidden by default?

A) They contain viruses and malware
B) They are typically configuration files that reduce clutter when hidden **[CORRECT]**
C) They are encrypted and cannot be read
D) They are system files that will crash the computer if viewed

### Question 2.7
What is TRUE about file extensions like `.csv` or `.py`?

A) They determine what programs can create the file
B) They are enforced by the operating system and cannot be changed
C) They are conventions that tell programs how to interpret the file **[CORRECT]**
D) They affect the actual binary content of the file

### Question 2.8
Which file format is described as "actually a ZIP archive containing XML files"?

A) .csv
B) .json
C) .xlsx **[CORRECT]**
D) .parquet

### Question 2.9
Why does version control (like Git) work better with text files than binary files?

A) Binary files are too large to store
B) Text files can track line-by-line changes meaningfully **[CORRECT]**
C) Binary files cannot be committed to repositories
D) Text files compress better than binary files

### Question 2.10
Given the path `../../shared/data/file.csv`, how many directory levels up does this path navigate before descending?

A) 0
B) 1
C) 2 **[CORRECT]**
D) 3

---

## Chapter 3: The Command Line

### Question 3.1
What is the relationship between a **terminal** and a **shell**?

A) They are the same thing
B) The terminal is the window; the shell interprets commands **[CORRECT]**
C) The shell is the window; the terminal interprets commands
D) The terminal runs inside the shell

### Question 3.2
What does the `pwd` command do?

A) Print the contents of a file
B) Print the current working directory **[CORRECT]**
C) Create a new directory
D) Delete a file

### Question 3.3
What does the `ls` command do?

A) List the contents of a directory **[CORRECT]**
B) Move to a different directory
C) Create a new file
D) Remove a directory

### Question 3.4
What does the `cd` command do?

A) Copy a directory
B) Create a directory
C) Change the current directory **[CORRECT]**
D) Clear the terminal display

### Question 3.5
In the command `ls -la ~/Documents`, what is `-la`?

A) An argument specifying a directory
B) A path to a file
C) Options/flags that modify the command's behavior **[CORRECT]**
D) The name of a file to list

### Question 3.6
What happens when you delete a file using `rm` on the command line?

A) The file moves to the Recycle Bin/Trash
B) The file is permanently deleted with no undo **[CORRECT]**
C) The file is backed up before deletion
D) The file is marked as hidden

### Question 3.7
What is **tab completion**?

A) A feature that creates new tabs in the terminal
B) A feature that auto-completes file and command names when you press Tab **[CORRECT]**
C) A feature that indents code automatically
D) A feature that opens multiple terminals

### Question 3.8
Which of the following is an advantage of using the command line over a GUI?

A) Command line interfaces are more visually appealing
B) Commands can be saved to scripts and automated **[CORRECT]**
C) Command line interfaces require less learning
D) Command line interfaces work without a keyboard

### Question 3.9
What is a **shell builtin**?

A) A program installed by the package manager
B) A command built into the shell itself, like `cd` **[CORRECT]**
C) A hardware component of the computer
D) A graphical element of the terminal window

### Question 3.10
The command `cd ..` will:

A) Move to the home directory
B) Move to the root directory
C) Move up one directory level (to the parent) **[CORRECT]**
D) Stay in the current directory

---

## Chapter 4: Version Control with Git

### Question 4.1
What are the three states/areas that files move through in Git?

A) Draft, Review, Published
B) Working Directory, Staging Area, Repository **[CORRECT]**
C) Local, Remote, Cloud
D) Created, Modified, Deleted

### Question 4.2
What does the `git init` command do?

A) Downloads a repository from GitHub
B) Creates a new Git repository in the current directory **[CORRECT]**
C) Commits all changes to the repository
D) Pushes changes to a remote server

### Question 4.3
What does the `git add` command do?

A) Creates a new file in the project
B) Moves changes from the working directory to the staging area **[CORRECT]**
C) Commits changes to the repository
D) Pushes changes to GitHub

### Question 4.4
What is a **commit** in Git?

A) A promise to finish a feature
B) A snapshot of your project at a specific point in time **[CORRECT]**
C) A request to merge branches
D) A connection to a remote repository

### Question 4.5
Why does Git require manual commits instead of autosaving like Google Docs?

A) Git was created before autosave technology existed
B) Autosave would use too much disk space
C) Code requires intentional checkpoints of working states, not every keystroke **[CORRECT]**
D) Git cannot detect when files change

### Question 4.6
What is the purpose of a **branch** in Git?

A) To permanently delete unwanted files
B) To create an independent line of development without affecting main **[CORRECT]**
C) To connect to a remote repository
D) To compress the repository for storage

### Question 4.7
What does the `.gitignore` file do?

A) Hides the Git repository from other users
B) Specifies files that Git should not track **[CORRECT]**
C) Lists all commits in the repository
D) Encrypts sensitive files in the repository

### Question 4.8
True or False: Git can only track changes that have been saved to disk.

A) True **[CORRECT]**
B) False

### Question 4.9
What command shows the current status of your Git repository, including staged and unstaged changes?

A) `git log`
B) `git diff`
C) `git status` **[CORRECT]**
D) `git show`

### Question 4.10
What does `git commit -m "message"` do?

A) Sends your changes to GitHub
B) Creates a snapshot with the provided description **[CORRECT]**
C) Merges two branches together
D) Reverts to a previous version

---

## Chapter 5: Collaboration with GitHub

### Question 5.1
What is the relationship between Git and GitHub?

A) They are the same software
B) Git is a version control system; GitHub is a hosting platform for Git repositories **[CORRECT]**
C) GitHub is a version control system; Git is a hosting platform
D) Git only works when connected to GitHub

### Question 5.2
What does `git clone` do?

A) Creates a new empty repository
B) Downloads a complete copy of a remote repository **[CORRECT]**
C) Uploads local changes to GitHub
D) Creates a branch of the current repository

### Question 5.3
What does `git push` do?

A) Downloads changes from a remote repository
B) Uploads local commits to a remote repository **[CORRECT]**
C) Creates a new branch
D) Merges two branches together

### Question 5.4
What does `git pull` do?

A) Uploads local commits to a remote repository
B) Downloads commits from a remote repository and merges them **[CORRECT]**
C) Creates a pull request on GitHub
D) Deletes a remote branch

### Question 5.5
What is a **pull request** on GitHub?

A) A request to download a repository
B) A proposal to merge changes from one branch into another **[CORRECT]**
C) A request to delete a repository
D) A request for more storage space

### Question 5.6
What is a **merge conflict**?

A) When two repositories cannot connect to each other
B) When Git cannot automatically combine changes because the same lines were modified differently **[CORRECT]**
C) When a branch is deleted accidentally
D) When GitHub servers are down

### Question 5.7
What is a **fork** on GitHub?

A) A tool for splitting large files
B) A personal copy of someone else's repository under your account **[CORRECT]**
C) A type of merge strategy
D) A way to delete repositories

### Question 5.8
What is the conventional name for the primary remote repository?

A) main
B) master
C) origin **[CORRECT]**
D) upstream

### Question 5.9
Why should you NEVER commit secrets (like API keys or passwords) to Git?

A) Git cannot store special characters
B) Secrets make the repository too large
C) Once in Git history, secrets are extremely difficult to remove completely **[CORRECT]**
D) GitHub automatically rejects commits with secrets

### Question 5.10
What is the purpose of **code review** in the pull request workflow?

A) To automatically fix bugs in the code
B) To examine changes for bugs, style, and clarity before merging **[CORRECT]**
C) To compress the code for faster performance
D) To convert code between programming languages

---

## Answer Key Summary

### Chapter 1: Computer Fundamentals
1.1: B | 1.2: C | 1.3: B | 1.4: C | 1.5: B | 1.6: B | 1.7: B | 1.8: B | 1.9: B | 1.10: A

### Chapter 2: Files and the File System
2.1: C | 2.2: B | 2.3: B | 2.4: C | 2.5: D | 2.6: B | 2.7: C | 2.8: C | 2.9: B | 2.10: C

### Chapter 3: The Command Line
3.1: B | 3.2: B | 3.3: A | 3.4: C | 3.5: C | 3.6: B | 3.7: B | 3.8: B | 3.9: B | 3.10: C

### Chapter 4: Version Control with Git
4.1: B | 4.2: B | 4.3: B | 4.4: B | 4.5: C | 4.6: B | 4.7: B | 4.8: A | 4.9: C | 4.10: B

### Chapter 5: Collaboration with GitHub
5.1: B | 5.2: B | 5.3: B | 5.4: B | 5.5: B | 5.6: B | 5.7: B | 5.8: C | 5.9: C | 5.10: B
