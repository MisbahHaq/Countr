#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

void fill_time(char *, int);
void fill_date(char *);
int input_format();
void clear_screen();

int main()
{
    char timeStr[50], date[100];

    int format = input_format();

    while (1)
    {
        fill_time(timeStr, format);
        fill_date(date);
        clear_screen();
        printf("Current Time: %s\n", timeStr);
        printf("Date: %s\n", date);
        sleep(1); // Wait 1 sec
    }
    return 0;
}

void clear_screen()
{
#ifdef _WIN32
    system("cls");
#else
    system("clear");
#endif
}
int input_format()
{
    int format;
    printf("\nChoose the Time Format: \n");
    printf("\n1. 24 Hour Format\n");
    printf("2. 12 Hour Format (default)\n");
    printf("\nMake a Choice (1/2): ");

    if (scanf("%d", &format) != 1 || (format != 1 && format != 2))
    {
        printf("\nInvalid input! Defaulting to 12-hour format.\n");
        format = 2;
    }
    return format;
}

void fill_date(char *buffer)
{
    time_t raw_time;
    struct tm *current_time;

    time(&raw_time);
    current_time = localtime(&raw_time);
    strftime(buffer, 100, "%A %B %d %Y", current_time);
}

void fill_time(char *buffer, int format)
{
    time_t raw_time;
    struct tm *current_time;

    time(&raw_time);
    current_time = localtime(&raw_time);
    if (format == 1)
    {
        strftime(buffer, 50, "%H:%M:%S", current_time);
    }
    else
    {
        strftime(buffer, 50, "%I:%M:%S %p", current_time);
    }
}
