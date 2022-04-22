//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Payroll {

    struct Employee {
        address addrEmployee;
        address addrBoss;
        uint wage;
        uint lastPaid;
    }

    struct Employer {
        uint deposit;
    }

    mapping(address => Employer) public employers; 
    mapping(address => Employee) public payroll;

    function deposit() public payable {
        employers[msg.sender].deposit += msg.value;
    }

    function newEmployee(address _addrEmployee, uint _wage) public {
        payroll[_addrEmployee].addrEmployee = _addrEmployee;
        payroll[_addrEmployee].addrBoss = msg.sender;
        payroll[_addrEmployee].wage = _wage;
        payroll[_addrEmployee].lastPaid = block.timestamp;
    }

    function claimSalary(address _addressBoss) public payable {
        require(msg.sender == payroll[msg.sender].addrEmployee, "You can't claim money");
        require(payroll[msg.sender].wage <= employers[_addressBoss].deposit, "Your company has not enough funds");
        require(payroll[msg.sender].addrBoss == _addressBoss, "You don't work for this company");
        require(block.timestamp >= payroll[msg.sender].lastPaid + 30 days, "You must wait 30 days for your next payment");
        payroll[msg.sender].lastPaid = block.timestamp;
        employers[_addressBoss].deposit -= payroll[msg.sender].wage;
        (bool success,) = msg.sender.call{value: payroll[msg.sender].wage}("");
        require(success, "Failed to send Ether");
    }

    function fireEmployee(address _addrEmployee) public {
        require(payroll[_addrEmployee].addrBoss == msg.sender, "This person is not your employee");
        payroll[_addrEmployee].addrBoss = 0x0000000000000000000000000000000000000000;
    }

    function changeWage(address _addrEmployee, uint _newWage) public {
        require(payroll[_addrEmployee].addrBoss == msg.sender, "This person is not your employee");
        payroll[_addrEmployee].wage = _newWage;
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
}
