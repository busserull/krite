defmodule Krite.DonationsTest do
  use Krite.DataCase

  alias Krite.Donations

  describe "donations" do
    alias Krite.Donations.Donation

    import Krite.DonationsFixtures

    @invalid_attrs %{item: nil, emoji: nil, quantity: nil, days_until_expires: nil}

    test "list_donations/0 returns all donations" do
      donation = donation_fixture()
      assert Donations.list_donations() == [donation]
    end

    test "get_donation!/1 returns the donation with given id" do
      donation = donation_fixture()
      assert Donations.get_donation!(donation.id) == donation
    end

    test "create_donation/1 with valid data creates a donation" do
      valid_attrs = %{item: "some item", emoji: "some emoji", quantity: 42, days_until_expires: 42}

      assert {:ok, %Donation{} = donation} = Donations.create_donation(valid_attrs)
      assert donation.item == "some item"
      assert donation.emoji == "some emoji"
      assert donation.quantity == 42
      assert donation.days_until_expires == 42
    end

    test "create_donation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Donations.create_donation(@invalid_attrs)
    end

    test "update_donation/2 with valid data updates the donation" do
      donation = donation_fixture()
      update_attrs = %{item: "some updated item", emoji: "some updated emoji", quantity: 43, days_until_expires: 43}

      assert {:ok, %Donation{} = donation} = Donations.update_donation(donation, update_attrs)
      assert donation.item == "some updated item"
      assert donation.emoji == "some updated emoji"
      assert donation.quantity == 43
      assert donation.days_until_expires == 43
    end

    test "update_donation/2 with invalid data returns error changeset" do
      donation = donation_fixture()
      assert {:error, %Ecto.Changeset{}} = Donations.update_donation(donation, @invalid_attrs)
      assert donation == Donations.get_donation!(donation.id)
    end

    test "delete_donation/1 deletes the donation" do
      donation = donation_fixture()
      assert {:ok, %Donation{}} = Donations.delete_donation(donation)
      assert_raise Ecto.NoResultsError, fn -> Donations.get_donation!(donation.id) end
    end

    test "change_donation/1 returns a donation changeset" do
      donation = donation_fixture()
      assert %Ecto.Changeset{} = Donations.change_donation(donation)
    end
  end
end
