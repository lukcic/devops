# Jira
Project management and issue tracking tool.\
Jira -> Gojira (Gozilla)

## Agile methodology
Jira is agile tool.

### Basics

Agile is a sfotware develoment methodology that is centered around helping teams get more stuff done by self-organizing therir work. Agile i ever-envolving ang changing. It's about constantly improving as a team.

### Agile Board

Columns - can (should) be customized
```
TO DO   | IN PROGRESS   | DONE
        |               |
        |               |
        |               |
        |               |
        |               |
        |               |
        |               |
        |               |
        |               |
```
2 primary ways to organize projects:
* Scrum - has sprints
* Kanban - doesn't

>Sprint - pre-determined amount of time where teams determine the work oto get done.

Example:
Our team decided on a wto week sprint - every two weeks, our team holds a sprint meeting:
* Start by discussing last sprint
    * What went well?
    * What didn't go well?
    * What can we do better next sprint?
    * Discuss and agree on the work bto be completed in next sprint?
* Give tasks a priorities
* you want to have as less tasks In progress as possible - one thing at time.

Kanban doesn't have a sprints so new tasks can be added to the board at an time.

---

## Agile Terminology

### User Story
```
As a < type of user >,
I want < some goal >,
so that < some reason >.
```
Ex:
> As a web developer, I want to be able to add users in Jira so that my coworkers can report bugs.

### Epic
An epic is a story that is too big for a single sprint. It's broken down into multiple user stories. When those are done, the epic is complete.

* Epic -  core functionality for app
    * Story 1
    * Story 2
    * Story 3

Stories in Jira = User stories
Stories - default method of organizing your projects inside Jira.

Epics in Jira contain multiple user stories.

### Issues

Containers that hold the fields that contain your data.
Issues are like post-it yellow notes. Can be custom.

Example fields:
* Description
* Summary
* Assignee
* Due date

### Projects

Organize things about your issues. Issues lives inside Jira projects. Used for different types of users (web dev, marketing, customer service).

### Backlog
Here new projects are created before team decide when to do them.

### Components
The way to group the issues that are related.

### Entities

Custom issue types, statuses, resolutions.

## Project types

### Team-managed projects

Team-managed projects don't need administrative permissions to create them.
All entities lives inside project.


### Company-managed projects

Classic project. Requires Jira administrative permissions to create. Entities can be shared between projects (company-managed).

In this project type we can have multiple project boards.
Issues from multiple projects can be seen anywhere.