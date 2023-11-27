// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrganDonation {
    address public procurementOrganizer;
    address public organMatchingOrganizer;

    enum BloodType {
        A,
        B,
        AB,
        O
    }
    enum OrganType {
        Heart,
        Lung,
        Liver,
        Kidney
    }

    struct Patient {
        uint256 id;
        uint256 age;
        uint256 bmi;
        BloodType bloodType;
        OrganType organType;
        bool isAssigned;
    }

    struct Donor {
        uint256 id;
        uint256 age;
        uint256 bmi;
        BloodType bloodType;
        OrganType organType;
        bool isRegistered;
    }

    mapping(uint256 => Patient) public patients;
    uint256 public patientCount;
    mapping(uint256 => Donor) public donors;
    uint256 public donorCount;
    mapping(address => bool) public assignedTransplantMembers;
    mapping(address => bool) public doctors;

    event NewPatientAdded(uint256 patientId);
    event DonorMedicalApproved(uint256 id);
    event MatchedPatients(uint256[] matchedPatients);

    constructor() {
        procurementOrganizer = msg.sender;
    }

    modifier onlyProcurementOrganizer() {
        require(
            msg.sender == procurementOrganizer,
            "Only procurement organizer can call this function"
        );
        _;
    }

    modifier onlyOrganMatchingOrganizer() {
        require(
            msg.sender == organMatchingOrganizer,
            "Only procurement organizer can call this function"
        );
        _;
    }

    modifier onlyAssignedDoctor() {
        require(
            doctors[msg.sender],
            "Only assigned doctor can call this function"
        );
        _;
    }

    modifier onlyTransplantTeamMember() {
        require(
            assignedTransplantMembers[msg.sender],
            "Only assigned transplant team member can call this function"
        );
        _;
    }

    function assignDoctor(address doctorAddress)
        external
        onlyProcurementOrganizer
    {
        doctors[doctorAddress] = true;
    }

    function assignOrganMatchingOrganizer(address _organMatchingOrganizer)
        external
        onlyProcurementOrganizer
    {
        organMatchingOrganizer = _organMatchingOrganizer;
    }

    function addNewPatient(
        uint256 id,
        uint256 age,
        uint256 bmi,
        uint256 bloodType,
        uint256 organType
    ) external onlyAssignedDoctor {
        require(!patients[id].isAssigned, "Patient already added");
        patients[id] = Patient(
            id,
            age,
            bmi,
            BloodType(bloodType),
            OrganType(organType),
            true
        );
        patientCount++;
        emit NewPatientAdded(id);
    }

    function assignTransplantTeamMember(address memberAddress)
        external
        onlyProcurementOrganizer
    {
        assignedTransplantMembers[memberAddress] = true;
    }

    function donorMedicalTestAndRegistration(
        uint256 id,
        uint256 age,
        uint256 bmi,
        BloodType bloodType,
        OrganType organType
    ) external onlyTransplantTeamMember {
        require(!donors[id].isRegistered, "Donor already registered");

        donors[id] = Donor(id, age, bmi, bloodType, organType, true);
        donorCount++;

        emit DonorMedicalApproved(id);
    }

    function matchingProcess(uint256 id) external returns (uint256[] memory) {
    require(
        msg.sender == organMatchingOrganizer,
        "Only organ matching organizer can call this function"
    );

    uint256 donorAge = donors[id].age;
    uint256 donorBMI = donors[id].bmi;
    uint256 donorBloodType = uint256(donors[id].bloodType);
    uint256 organType = uint256(donors[id].organType);

    uint256 minAge = donorAge - 10;
    uint256 maxAge = donorAge + 10;
    uint256 minBMI = donorBMI - 1;
    uint256 maxBMI = donorBMI + 1;

    uint256[] memory matchedPatients = new uint256[](patientCount);
    uint256 count = 0;

    for (uint256 i = 1; i <= patientCount; i++) {
        if (
            patients[i].organType == OrganType(organType) &&
            patients[i].age >= minAge &&
            patients[i].age <= maxAge &&
            uint256(patients[i].bloodType) == donorBloodType &&
            patients[i].bmi >= minBMI &&
            patients[i].bmi <= maxBMI &&
            patients[i].isAssigned
        ) {
            matchedPatients[count] = patients[i].id;
            count++;
        }
    }

    emit MatchedPatients(matchedPatients);

    return matchedPatients;
}

}
