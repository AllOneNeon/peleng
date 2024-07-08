import requests
from bs4 import BeautifulSoup



url = "https://terrikon.com/football/italy/championship/"

response = requests.get(url)
soup = BeautifulSoup(response.content, "html.parser")

table = soup.find("table")

player_data = []

for row in table.find_all("tr")[1:]:
    columns = row.find_all("td")
    player_name = columns[1].text.strip()
    team = columns[2].text.strip()
    goals_scored = int(columns[3].text.strip())
    games_played = int(columns[4].text.strip())
    average_goals = float(columns[5].text.strip())
    
    player_data.append({
        "Игрок": player_name,
        "Команда": team,
        "Забито": goals_scored,
        "Игр": games_played,
        "Среднее": average_goals
    })

for player in player_data:
    print(f"Игрок: {player['Игрок']}, Команда: {player['Команда']}, Забито: {player['Забито']}, Игр: {player['Игр']}, Среднее: {player['Среднее']:.2f}")
