# Class Diagram - UML

Team Guardians of the Galaxy: Cheng Cheng, Kevin Van, Morgan Levy, Daniel Hartanto

Uml Diagram for Husky Express, our teams vision for a NEU: Seattle Campus carpool mobile application

```mermaid
---
title: Husky Express UML Diagram
---
classDiagram

    User <|-- Host
    User <|-- Rider
    Post <|-- Ride

    Host "1" --o "*" Post : creates
    Rider "1" --o "*" Post : requests rides on
    Rider "*" --o "*" Ride : takes a
    Host "1" --o "*" Ride : hosts a
    Post "1" --o "1" Ride 

    class User {
        + Int userId
        + String email
        + String firstName
        + String lastName
        + Int pfpId
        + Int phoneNumber
        + String homeAddress
        + List<Int> rideIds
        + Map<String, String> savedLocations

        + get()
        + set() 
    }

    class Host {
        + List<Post> hostedRides

        + postRide()
        + editRide()
        + labelRideComplete()
        + requestResponse(Int rideId, Int requesterId) bool
    }

    class Rider{
        + List<Post> myRides
        + getMyRides()
    }

    class Post {
        + Int rideId 
        + Host userId
        + Int ridesDriven 
        + List<Int> riderIds 
        + String pickUpAddr 
        + Date ridePickUpDateAndTime 
        + String pickUpDetails 
        + String destinationAddr 
        + Date rideArrivalDateAndTime 
        + String carMakeAndModel 
        + String carColor 
        + String licensePlate 
        + Int availableSeats 
        + Bool completed 

        + get()
        + set()
        + addPassenger(userId)
    }

    class Ride {
        + enum status
        + List <userId> riders
        + get()
        + set()
    }

    class Status {
        enum [Pending, Accept, Reject]
    }
```