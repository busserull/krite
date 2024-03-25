defmodule Krite.AccountsTest do
  use Krite.DataCase

  alias Krite.Accounts

  describe "kveg" do
    alias Krite.Accounts.Kveg

    import Krite.AccountsFixtures

    @invalid_attrs %{
      active: nil,
      balance: nil,
      firstname: nil,
      lastname: nil,
      subtitle: nil,
      email: nil,
      sauna_pass_end: nil
    }

    test "list_kveg/0 returns all kveg" do
      kveg = kveg_fixture()
      assert Accounts.list_kveg() == [kveg]
    end

    test "get_kveg!/1 returns the kveg with given id" do
      kveg = kveg_fixture()
      assert Accounts.get_kveg!(kveg.id) == kveg
    end

    test "create_kveg/1 with valid data creates a kveg" do
      valid_attrs = %{
        active: true,
        balance: 42,
        firstname: "some firstname",
        lastname: "some lastname",
        subtitle: "some subtitle",
        email: "some email",
        sauna_pass_end: ~N[2023-12-04 14:18:00]
      }

      assert {:ok, %Kveg{} = kveg} = Accounts.create_kveg(valid_attrs)
      assert kveg.active == true
      assert kveg.balance == 42
      assert kveg.firstname == "some firstname"
      assert kveg.lastname == "some lastname"
      assert kveg.subtitle == "some subtitle"
      assert kveg.email == "some email"
      assert kveg.sauna_pass_end == ~N[2023-12-04 14:18:00]
    end

    test "create_kveg/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_kveg(@invalid_attrs)
    end

    test "update_kveg/2 with valid data updates the kveg" do
      kveg = kveg_fixture()

      update_attrs = %{
        active: false,
        balance: 43,
        firstname: "some updated firstname",
        lastname: "some updated lastname",
        subtitle: "some updated subtitle",
        email: "some updated email",
        sauna_pass_end: ~N[2023-12-05 14:18:00]
      }

      assert {:ok, %Kveg{} = kveg} = Accounts.update_kveg(kveg, update_attrs)
      assert kveg.active == false
      assert kveg.balance == 43
      assert kveg.firstname == "some updated firstname"
      assert kveg.lastname == "some updated lastname"
      assert kveg.subtitle == "some updated subtitle"
      assert kveg.email == "some updated email"
      assert kveg.sauna_pass_end == ~N[2023-12-05 14:18:00]
    end

    test "update_kveg/2 with invalid data returns error changeset" do
      kveg = kveg_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_kveg(kveg, @invalid_attrs)
      assert kveg == Accounts.get_kveg!(kveg.id)
    end

    test "delete_kveg/1 deletes the kveg" do
      kveg = kveg_fixture()
      assert {:ok, %Kveg{}} = Accounts.delete_kveg(kveg)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_kveg!(kveg.id) end
    end

    test "change_kveg/1 returns a kveg changeset" do
      kveg = kveg_fixture()
      assert %Ecto.Changeset{} = Accounts.change_kveg(kveg)
    end
  end
end
