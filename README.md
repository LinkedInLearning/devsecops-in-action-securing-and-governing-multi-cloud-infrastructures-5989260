# DevSecOps in Action: Securing and Governing Multi-Cloud Infrastructures
This is the repository for the LinkedIn Learning course DevSecOps in Action: Securing and Governing Multi-Cloud Infrastructures. The full course is available from [LinkedIn Learning][lil-course-url].

![lil-thumbnail-url]

## Course Description

Organizations are increasingly adopting multicloud strategies for performance, reliability, and cost efficiency—but this creates challenges in security, visibility, and governance. In this course, Emmanuel Chebukati, a certified cloud security engineer, demonstrates practical DevSecOps approaches for AWS and Azure. Topics include deploying applications with Terraform, automating resources across clouds, enabling zero trust access, managing secrets with Doppler, monitoring dependency risks with Dependabot, and setting up incident responses. Emmanuel also covers how to enforce policy guardrails using Open Policy Agent and track compliance through automated systems. Designed for cloud security strategists, senior cloud architects, DevOps team leads, and directors managing cloud initiatives, this course offers hands-on demos and real-world simulations to help you apply these practices to secure, monitor, and govern multicloud environments effectively.

_See the readme file in the main branch for updated instructions and information._
## Instructions
This repository has branches for each of the videos in the course. You can use the branch pop up menu in github to switch to a specific branch and take a look at the course at that stage, or you can add `/tree/BRANCH_NAME` to the URL to go to the branch you want to access.

## Branches
The branches are structured to correspond to the videos in the course. The naming convention is `CHAPTER#_MOVIE#`. As an example, the branch named `02_03` corresponds to the second chapter and the third video in that chapter. 
Some branches will have a beginning and an end state. These are marked with the letters `b` for "beginning" and `e` for "end". The `b` branch contains the code as it is at the beginning of the movie. The `e` branch contains the code as it is at the end of the movie. The `main` branch holds the final state of the code when in the course.

When switching from one exercise files branch to the next after making changes to the files, you may get a message like this:

    error: Your local changes to the following files would be overwritten by checkout:        [files]
    Please commit your changes or stash them before you switch branches.
    Aborting

To resolve this issue:
	
    Add changes to git using this command: git add .
	Commit changes using this command: git commit -m "some message"

## Instructor

Emmanuel Chebukati

Certified Cloud and DevSecOps Engineer | Cybersecurity Instructor              

Check out my other courses on [LinkedIn Learning](https://www.linkedin.com/learning/instructors/emmanuel-chebukati?u=104).


[0]: # (Replace these placeholder URLs with actual course URLs)

[lil-course-url]: https://www.linkedin.com/learning/devsecops-in-action-securing-and-governing-multicloud-infrastructures
[lil-thumbnail-url]: https://media.licdn.com/dms/image/v2/D560DAQEpAN4FrRqsAw/learning-public-crop_675_1200/B56ZqYWuuqHQAY-/0/1763492687533?e=2147483647&v=beta&t=6QEN6Ega9q34CprfMsW_EkkLhcH_teqe3kMrp8WrHO0
