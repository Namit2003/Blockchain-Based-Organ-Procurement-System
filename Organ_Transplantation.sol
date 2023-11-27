// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrganTransplantation {
    address public donorSurgeon;
    address public transplantSurgeon;
    address public transporter;
    address public contractOwner;
    
    enum OrganStatus { NotReady, ReadyforDelivery, OnTrack, EndDelivery, OrganReceived }
    OrganStatus public organState;
    
    event OrganRemoved(uint donorId, uint removingDate, uint removingTime, uint organType);
    event OrganReadyForDelivery();
    event OrganOnTrack();
    event OrganEndDelivery();
    event OrganReceived();
    event OrganTransplanted(uint patientId, uint transplantationDate, uint transplantationTime);
    
    constructor() {
        contractOwner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner can call this function");
        _;
    }

    function setDonorSurgeon(address _donorSurgeon) external onlyOwner {
        donorSurgeon = _donorSurgeon;
    }

    function setTransplantSurgeon(address _transplantSurgeon) external onlyOwner {
        transplantSurgeon = _transplantSurgeon;
    }

    function setTransporter(address _transporter) external onlyOwner {
        transporter = _transporter;
    }
    
    modifier onlyDonorSurgeon() {
        require(msg.sender == donorSurgeon, "Only donor surgeon can call this function");
        _;
    }
    
    modifier onlyTransplantSurgeon() {
        require(msg.sender == transplantSurgeon, "Only transplant surgeon can call this function");
        _;
    }
    
    modifier onlyTransporter() {
        require(msg.sender == transporter, "Only assigned transporter can call this function");
        _;
    }
    
    function removeDonatedOrgan(uint donorId, uint removingDate, uint removingTime, uint organType) external onlyDonorSurgeon {
        require(organState == OrganStatus.NotReady, "Organ already removed or in transit");
        emit OrganRemoved(donorId, removingDate, removingTime, organType);
        organState = OrganStatus.ReadyforDelivery;
        emit OrganReadyForDelivery();
    }
    
    function startDelivery() external onlyTransporter {
        require(organState == OrganStatus.ReadyforDelivery, "Organ not ready for delivery");
        organState = OrganStatus.OnTrack;
        emit OrganOnTrack();
    }
    
    function endDelivery() external onlyTransporter {
        require(organState == OrganStatus.OnTrack, "Organ delivery not in progress");
        organState = OrganStatus.EndDelivery;
        emit OrganEndDelivery();
    }
    
    function receiveOrgan() external onlyTransplantSurgeon {
        require(organState == OrganStatus.EndDelivery, "Organ not delivered yet");
        organState = OrganStatus.OrganReceived;
        emit OrganReceived();
    }
    
    function performTransplantation(uint patientId, uint transplantationDate, uint transplantationTime) external onlyTransplantSurgeon {
        require(organState == OrganStatus.OrganReceived, "Organ not received yet");
        emit OrganTransplanted(patientId, transplantationDate, transplantationTime);
    }
}
