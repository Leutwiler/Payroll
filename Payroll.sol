//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Payroll {

//Array de nome, address e salário
//Consultar total a pagar de salário
//Pagar salário

    struct Employee {
        address addrEmployee;
        address addrBoss;
        uint wage;
        bool employed;
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
        payroll[_addrEmployee].employed = true;
    }

    function claimSalary(address _addressBoss) public payable {
        require(msg.sender == payroll[msg.sender].addrEmployee, "You can't claim money");
        require(payroll[msg.sender].wage <= employers[_addressBoss].deposit, "Your company has not enough funds");
        require(payroll[msg.sender].employed = true, "You don't work for this company anymore");
        employers[msg.sender].deposit -= payroll[msg.sender].wage;
        //Verificar se o empregado só pode tirar o dinheiro da própria empresa + contabilizar tempo para próxima retirada
        (bool success,) = msg.sender.call{value: payroll[msg.sender].wage}("");
        require(success, "Failed to send Ether");
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
}
