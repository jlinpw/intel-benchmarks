import csv
import pandas as pd
import matplotlib.pyplot as plt
import plotly.offline as py
import plotly.tools as tls
import sys


def process(input_file, output_file, processes):
    # Read the input file
    with open(input_file, "r") as file:
        data = file.readlines()

    # Find the start and end indices of the table using the # processes line
    start_line = f"# #processes = {processes} \n"
    start_index = data.index(start_line)
    end_index = data.index("# All processes entering MPI_Finalize\n")

    # Extract the table data
    table_data = [line.strip() for line in data[start_index:end_index]]
    if input_file.endswith("pingpong.txt"):
        for _ in range(4):
            table_data.pop(0)
        d = [line.split() for line in table_data]
    else:
        for _ in range(3):
            table_data.pop(0)
        d = [line.split() for line in table_data]

    for _ in range(3):
        d.pop()

    # Write the data to a CSV file
    with open(output_file, "w", newline="") as file:
        writer = csv.writer(file)
        if input_file.endswith("pingpong.txt"):
            writer.writerow(["#bytes", "#repetitions", "t[usec]", "Mbytes/sec"])
        else:
            writer.writerow(
                ["#bytes", "#repetitions", "t_min[usec]", "t_max[usec]", "t_avg[usec]"]
            )
        writer.writerows(d)

    return [start_index, end_index]


# TODO: save as html file so it can be viewed in browser
def graph(csv, y, figname):
    df = pd.read_csv(csv)

    fig = plt.figure()
    # Plot the data
    plt.plot(df["#bytes"], df[y])

    ylab = y + " (log scale)"

    # Customize the plot
    plt.xlabel("bytes")
    plt.ylabel(ylab)
    plt.title("IMB-MPI1 Benchmark")
    plt.grid(True)
    plt.yscale("log")
    plt.xscale("log")

    # Convert to plotly figure
    fig = plt.gcf()
    plotly_fig = tls.mpl_to_plotly(fig)
    py.plot(plotly_fig, filename=figname, auto_open=False)


def plot_data(txt, csv, html, processes, y):
    s, e = process(txt, csv, processes)
    graph(csv, y, html)


if __name__ == "__main__":
    if len(sys.argv) > 2:
        processes = sys.argv[2]
        pingpong = "test_files/pingpong"
        alltoall = "test_files/alltoall"
    else:
        processes = sys.argv[1]
        pingpong = "pingpong"
        alltoall = "alltoall"

    plot_data(
        alltoall + ".txt",
        alltoall + ".csv",
        alltoall + ".html",
        processes,
        "t_avg[usec]",
    )
    plot_data(pingpong + ".txt", pingpong + ".csv", pingpong + ".html", 2, "Mbytes/sec")
