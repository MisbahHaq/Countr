#include <stdio.h>
#include <time.h>

void fill_time(char *, int);
void fill_date(char *);
int input_format();

int main()
{
    char time[50], date[100];

    int format = input_format();
    fill_time(time, format);
    fill_date(date);
    printf("\nCurrent Time: %s\n", time);
    printf("\nDate: %s\n", date);
    return 0;
}

int input_format()
{
    int format;
    printf("\nChoose the Time Format: \n");
    printf("\n1. 24 Hour Format");
    printf("\n2. 12 Hour Format (default)\n");
    printf("\nMake a Choice:(1/2) ");
    scanf("%d", &format);
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
