# Payroll

In this repository you can find a payroll tool where companies can add new employees to their payroll, change their wages or even fire them, while also being able to deposit money for workers. Employees can claim their salary once every 30 days.

The main goal of this project is to provide a tool in the blockchain for companies to pay their employees with ether.

This is my second Solidity project :)

## Base of our code 👨‍💻

The following code represents the base of all the project. We're creating two structs, one for the employers and the other for the employees. The employee struct has the addresses of both the company and the employee as well as his/her wage and the date of the last payment.

There are two mappings which links an address to the structs. These mappings are called employers and payroll.

```
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
```

## Functions for the company 🏦

The functions of the code that are designed for companies are:
* deposit: you can deposit the amount of ether that you're going to use to pay your employees
* newEmployee: you can add a new worker to the payroll system by filling his/her address and wage
* fireEmployee: you can also fire employees that don't work for your company anymore (resets their addrBoss to the zero address)
* changeWage: use it to change the wage of your workers
* getContractBalance: both companies and employees can use this function, which returns the total balance of the contract

```
    function deposit() public payable {
        employers[msg.sender].deposit += msg.value;
    }

    function newEmployee(address _addrEmployee, uint _wage) public {
        payroll[_addrEmployee].addrEmployee = _addrEmployee;
        payroll[_addrEmployee].addrBoss = msg.sender;
        payroll[_addrEmployee].wage = _wage;
        payroll[_addrEmployee].lastPaid = block.timestamp;
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
```

## Functions for the employees 🙋‍♂️

This function refers to our claim salary system. There's only one input which is the address of your company.

It has four requires:

1) Checks if the address of the msg.sender is the same as the address of the employee
2) Secures that your company has enough funds for paying you
3) Makes sure the inputed address is really the address of the company that you work for
4) Ensures that you can't infinitely claim the money, otherwise an employee could steal all the money deposited by the company to pay their workers. You must wait 30 days in other to claim your wage again.

Afterwards, the function updates the timestamp of your last payment, reduces the amount deposited and then transfers the salary to the employee.

Doing so in this specific order avoids the reentrancy hack!

```
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
```

## Thanks 😄

Thanks for reading my code! This is my second Solidity project! I'm happy because this payroll tool is more in line with big projects that are done in Solidity when compared to my first one! I can easily notice my evolution at each project.

If you would like to talk to me, feel free to text me on Twitter or LinkedIn.