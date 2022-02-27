alias Cafe.Accounts.User
alias Cafe.Teams.{Team, TeamsQuery}
alias Cafe.Groups.Group
alias Cafe.Repo

Mix.env() == "test" && import Cafe.{AccountsFixtures, GroupsFixtures, TeamsFixtures}
