def sort_numbers_from_string(input_string):
    words = input_string.split()
    numbers = [int(word) for word in words if word.lstrip('-').isdigit()]
    sorted_numbers = sorted(numbers)
    print(*sorted_numbers)

input_string = "1 -2 -3 4 5 -6f ss3 0 0 0 -0 0.0 0.05"
sort_numbers_from_string(input_string)
