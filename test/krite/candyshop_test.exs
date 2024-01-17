defmodule Krite.CandyshopTest do
  use Krite.DataCase

  alias Krite.Candyshop

  describe "candies" do
    alias Krite.Candyshop.Candy

    import Krite.CandyshopFixtures

    @invalid_attrs %{name: nil, calories: nil}

    test "list_candies/0 returns all candies" do
      candy = candy_fixture()
      assert Candyshop.list_candies() == [candy]
    end

    test "get_candy!/1 returns the candy with given id" do
      candy = candy_fixture()
      assert Candyshop.get_candy!(candy.id) == candy
    end

    test "create_candy/1 with valid data creates a candy" do
      valid_attrs = %{name: "some name", calories: 42}

      assert {:ok, %Candy{} = candy} = Candyshop.create_candy(valid_attrs)
      assert candy.name == "some name"
      assert candy.calories == 42
    end

    test "create_candy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Candyshop.create_candy(@invalid_attrs)
    end

    test "update_candy/2 with valid data updates the candy" do
      candy = candy_fixture()
      update_attrs = %{name: "some updated name", calories: 43}

      assert {:ok, %Candy{} = candy} = Candyshop.update_candy(candy, update_attrs)
      assert candy.name == "some updated name"
      assert candy.calories == 43
    end

    test "update_candy/2 with invalid data returns error changeset" do
      candy = candy_fixture()
      assert {:error, %Ecto.Changeset{}} = Candyshop.update_candy(candy, @invalid_attrs)
      assert candy == Candyshop.get_candy!(candy.id)
    end

    test "delete_candy/1 deletes the candy" do
      candy = candy_fixture()
      assert {:ok, %Candy{}} = Candyshop.delete_candy(candy)
      assert_raise Ecto.NoResultsError, fn -> Candyshop.get_candy!(candy.id) end
    end

    test "change_candy/1 returns a candy changeset" do
      candy = candy_fixture()
      assert %Ecto.Changeset{} = Candyshop.change_candy(candy)
    end
  end
end
