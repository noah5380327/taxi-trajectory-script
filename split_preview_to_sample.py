import csv
import ast
from datetime import datetime, timedelta

input_file = 'preview.csv'
output_traj = 'trajectories_sample.csv'
output_points = 'trajectory_points_sample.csv'

max_trajectories = 50
trajectory_id = 1
point_id = 1

with open(input_file, 'r') as infile, \
        open(output_traj, 'w', newline='') as traj_out, \
        open(output_points, 'w', newline='') as point_out:

    reader = csv.DictReader(infile)
    traj_writer = csv.writer(traj_out)
    point_writer = csv.writer(point_out)

    traj_writer.writerow(['id', 'taxi_id', 'trajectory_date'])
    point_writer.writerow(['id', 'trajectory_id', 'lat', 'lon', 'timestamp'])

    for row in reader:
        if trajectory_id > max_trajectories:
            break

        taxi_id = row['TAXI_ID']
        ts = int(row['TIMESTAMP'])
        points = ast.literal_eval(row['POLYLINE'])

        if len(points) == 0:
            continue

        date_str = datetime.utcfromtimestamp(ts).strftime('%Y-%m-%d')
        traj_writer.writerow([trajectory_id, taxi_id, date_str])

        current_time = datetime.utcfromtimestamp(ts)

        for p in points:
            lat, lon = p
            point_writer.writerow([point_id, trajectory_id, lat, lon, current_time])
            point_id += 1
            current_time += timedelta(seconds=15)

        trajectory_id += 1

print("✅ Done！trajectories_sample.csv and trajectory_points_sample.csv")
