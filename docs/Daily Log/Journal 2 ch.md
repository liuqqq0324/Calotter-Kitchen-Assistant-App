# COMPSCI 778 – Journal Two

## Project Description and Background

In our endeavor to develop the Food Waste Tracker Application, we aim to improve how food waste is measured and quantified in small restaurants. This project emerged from the need for a more efficient method than the current practices in New Zealand, where waste tracking involves manual collection and weighing, a process both time-consuming and impractical.

---

## Goals and Objectives

Our primary goal is to create an application that enables restaurant owners to effectively record their food waste and associated costs. This tool is envisioned not just as a means for operational efficiency but also as a crucial data source for researchers. This tool is envisioned not just as a means for operational efficiency but also as a crucial data source for researchers.

---

## Progress and Development

The journey so far has been a blend of collaboration and innovation. We have collectively designed the user interface and the database, establishing a robust foundation for our application. Our chosen technology stack includes React.js for the frontend and Node.js, Express.js for the backend, with SQLite for database management. A significant milestone was the creation of our app's initial prototype using Figma, which brought our concept closer to reality. During this phase, we encountered challenges such as ensuring seamless integration of different technologies, which we overcame through iterative testing and collaborative problem-solving.

The application is designed with several key components, and these have been implemented:

- **Dashboard**  
  Tailored for government officials, featuring data visualization tools such as pie charts and bar charts to display waste categories and trends over time, along with a ranking list for regional waste comparison.

- **Inventory Section**  
  Allows users to track their total food stock, usage, waste, and expiry details.

- **Report Page**  
  Provides insights into near-expiry and wasted food items.

- **Notice Page**  
  Planned to include notifications for expiring items.

- **Guide Page**  
  Will offer tips for reducing waste and instructions for using the app effectively.

- **Profile Page**  
  Enables users to manage their personal and restaurant information.

My role in this project has been integral. I have participated in UI design and database development, but my main focus has been writing code. I have been involved in developing both the front-end and back-end aspects of the application. This project is not just a technical challenge but also a meaningful endeavor to address a significant environmental issue. The potential impact of our application in reducing food waste and aiding research is a driving force for our team, and I am eager to see how our efforts will contribute to this vital cause.

---

## Future Plans and Expectations

Looking ahead, we plan to integrate login and logout functionalities and ensure the application’s design is responsive for mobile users. Simplifying user input, possibly through a barcode scanning feature, is also on our agenda. Anticipated challenges include ensuring data security and designing an intuitive user interface for mobile platforms, which we plan to address through rigorous testing and user feedback.

---

## Literature Review on REST API

In the development of our Food Waste Tracker Application, a significant portion of my responsibility involves writing backend APIs. To ensure the effectiveness and efficiency of these APIs, I conducted a literature review focusing on REST (Representational State Transfer) APIs, a cornerstone of modern web services and application development.

REST, conceptualized by Roy Fielding in his 2000 doctoral dissertation, is a set of guidelines for creating networked applications rather than a technology or a standard (Fielding, 2000). The literature outlines six guiding constraints that ensure RESTful APIs are scalable, reliable, and performant.

### REST Architectural Principles

#### Uniform Interface

This principle involves using a consistent interface for interacting with resources, decoupling client and server implementations. Standard HTTP methods (GET, POST, PUT, DELETE) and URIs are used to interact with resources (Fielding, 2000).

#### Stateless Operations

Each request from the client must contain all information necessary for the server to process it. The server does not store client session state, which enhances scalability and reliability (Fielding, 2000).

#### Cacheable Responses

Responses can be cached by clients to reduce redundant requests and improve efficiency. Proper cache control significantly enhances performance (Fielding, 2000).

#### Client-Server Architecture

This separation of concerns allows user interfaces and data storage to evolve independently, improving portability and scalability (Fielding, 2000).

#### Layered System

A layered architecture structures the application into hierarchical layers, improving scalability, security, and manageability. Clients cannot typically distinguish between end servers and intermediaries (Fielding, 2000).

#### Code on Demand (Optional)

This optional constraint allows client functionality to be extended by executing downloaded code, simplifying client implementations (Fielding, 2000).

### Advantages and Challenges of REST APIs

Numerous sources highlight the advantages of REST APIs, including simplicity, scalability, and flexibility. REST’s use of standard HTTP methods and its stateless nature allow systems to handle large volumes of requests efficiently (Pautasso, Zimmermann, & Leymann, 2008).

However, the literature also identifies challenges, such as designing APIs that strictly adhere to REST principles and managing security and authentication in stateless systems (Allamaraju, 2010).

The insights gained from this literature review directly inform the backend API design of the Food Waste Tracker Application. These principles guide decisions to ensure the system is scalable, robust, and effective in addressing food waste management challenges.

---

## References

- Allamaraju, S. (2010). *RESTful Web Services Cookbook*. O'Reilly Media.  
- Fielding, R. (2000). *Architectural Styles and the Design of Network-based Software Architectures*. Doctoral dissertation, University of California, Irvine.  
- Pautasso, C., Zimmermann, O., & Leymann, F. (2008). *RESTful Web Services vs. "Big" Web Services: Making the Right Architectural Decision*. Proceedings of the 17th International World Wide Web Conference (WWW2008).  
- Rodriguez, A. (2010). *RESTful Web Services: The Basics*. IBM DeveloperWorks.