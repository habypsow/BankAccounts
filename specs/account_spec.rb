require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'
require_relative '../lib/account'

describe "Wave 1" do

  describe "Account#initialize" do
    it "Takes an ID and an initial balance" do
      id = 1337
      balance = 100.0
      account = Bank::Account.new(id, balance)

      account.must_respond_to :id
      account.id.must_equal id
      
      account.must_respond_to :balance
      account.balance.must_equal balance
    end

    it "Raises an ArgumentError when created with a negative balance" do
      proc {
        Bank::Account.new(1337, -100.0)
      }.must_raise ArgumentError
    end

    it "Can be created with a balance of 0" do
      Bank::Account.new(1337, 0)
    end
  end

  describe "Account#withdraw" do
    it "Reduces the balance" do
      start_balance = 100.0
      withdrawal_amount = 25.0
      account = Bank::Account.new(1337, start_balance)
      account.withdraw(withdrawal_amount)
      expected_balance = start_balance - withdrawal_amount
      account.balance.must_equal expected_balance
    end

    it "Returns the modified balance" do
      start_balance = 100.0
      withdrawal_amount = 25.0
      account = Bank::Account.new(1337, start_balance)

      updated_balance = account.withdraw(withdrawal_amount)
      expected_balance = start_balance - withdrawal_amount
      updated_balance.must_equal expected_balance
    end

    it "Outputs a warning if the account would go negative" do
      start_balance = 100.0
      withdrawal_amount = 200.0
      account = Bank::Account.new(1337, start_balance)

      proc { account.withdraw(withdrawal_amount)
      }.must_output(/.+/)
    end

    it "Doesn't modify the balance if the account would go negative" do
      start_balance = 100.0
      withdrawal_amount = 200.0
      account = Bank::Account.new(1337, start_balance)

      updated_balance = account.withdraw(withdrawal_amount)
      updated_balance.must_equal start_balance
      account.balance.must_equal start_balance
    end

    it "Allows the balance to go to 0" do
      account = Bank::Account.new(1337, 100.0)

      updated_balance = account.withdraw(account.balance)
      updated_balance.must_equal 0
      account.balance.must_equal 0
    end

    it "Requires a positive withdrawal amount" do
      start_balance = 100.0
      withdrawal_amount = -25.0
      account = Bank::Account.new(1337, start_balance)

      proc {
        account.withdraw(withdrawal_amount)
      }.must_raise ArgumentError
    end
  end

  describe "Account#deposit" do
    it "Increases the balance" do
      start_balance = 100.0
      deposit_amount = 25.0
      account = Bank::Account.new(1337, start_balance)

      account.deposit(deposit_amount)
      expected_balance = start_balance + deposit_amount
      account.balance.must_equal expected_balance
    end

    it "Returns the modified balance" do
      start_balance = 100.0
      deposit_amount = 25.0
      account = Bank::Account.new(1337, start_balance)

      updated_balance = account.deposit(deposit_amount)
      expected_balance = start_balance + deposit_amount
      updated_balance.must_equal expected_balance
    end

    it "Requires a positive deposit amount" do
      start_balance = 100.0
      deposit_amount = -25.0
      account = Bank::Account.new(1337, start_balance)

      proc {
        account.deposit(deposit_amount)
      }.must_raise ArgumentError
    end
  end
end

describe "Wave 2" do
  describe "Account.all" do
    it "Returns an array of all accounts" do

      account = Bank::Account.all

      account.must_be_instance_of Array

      #   - Everything in the array is an Account
      account.each do |element|
        element.must_be_instance_of Bank::Account
      end
      #   - The number of accounts is correct account.length = 12
      account.length.must_equal 12 #CSV.read("support/accounts.csv").length
      #   - The ID and balance of the first and last ...pull out indexes, id must be equal to
      #       accounts match what's in the CSV file
      account[0].id.must_equal 1212
      account[-1].id.must_equal 15156
      account[0].balance.must_equal 1235667
      account[-1].balance.must_equal 4356772
      # Feel free to split this into multiple tests if needed
    end

    describe "Account.find" do
      it "Returns an account that exists" do
        account = Bank::Account.find(1212)
        account.must_be_instance_of Bank::Account
      end

      it "Can find the first account from the CSV" do
        accounts = Bank::Account.all
        account = Bank::Account.find(1212)
        account.id.must_equal accounts[0].id
      end

      it "Can find the last account from the CSV" do
        accounts = Bank::Account.all
        account = Bank::Account.find(15156)
        account.id.must_equal accounts[-1].id
      end

      it "Raises an error for an account that doesn't exist" do
        proc { Bank::Account.find(111111)
        }.must_output(/.+/)
      end
    end
  end
end
