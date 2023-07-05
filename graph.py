import csv
import pandas as pd
import matplotlib.pyplot as plt


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
    if input_file == "pingpong.txt":
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
        if input_file == "pingpong.txt":
            writer.writerow(["#bytes", "#repetitions", "t[usec]", "Mbytes/sec"])
        else:
            writer.writerow(
                ["#bytes", "#repetitions", "t_min[usec]", "t_max[usec]", "t_avg[usec]"]
            )
        writer.writerows(d)

    return [start_index, end_index]


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

    # Show & save the plot
    plt.show()
    fig.savefig(figname)


if __name__ == "__main__":
    s, e = process("pingpong.txt", "pingpong.csv", 2)
    # debug
    #print(s, e)
    # graph
    graph("pingpong.csv", "Mbytes/sec", "pingpong.png")

    t, f = process("alltoall.txt", "alltoall.csv", 4)
    # debug
    #print(t, f)
    # graph
    graph("alltoall.csv", "t_avg[usec]", "alltoall.png")