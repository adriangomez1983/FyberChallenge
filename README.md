# FyberChallenge
Here is the implementation of the proposed challenge

<h2>Design decisions and assumptions</h2>
* Every request must to be signed and every response must to be validated as suggested in the documentation
* In case of response validation failure always retry
* If more than one page is needed always retrieve all the data
* In case of a request failure, display the error message in a human readable way
* One call at a time is supported
* The code is splitted thinking about a component for retrieving the requested data from the given API independently of the UI implementation 

<h2>Test cases</h2>
* The test cases were implemented using OCMock and XCTest trying to exercise all of the most methods

<h2>Improvements</h2>
* Support multiple calls
* Caching
* Persistance

<h2>A class diagram </h2>
![Alt text](/../master/Diagrams/classes.png?raw=true "Optional Title")
