#!/usr/bin/env python3
import re
import subprocess
from collections import defaultdict
from datetime import datetime

from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text


def get_nh_info():
    """Получает вывод команды nh os info"""
    try:
        result = subprocess.run(
            ["nh", "os", "info"], capture_output=True, text=True, check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Ошибка при выполнении nh os info: {e}")
        return None
    except FileNotFoundError:
        print("Команда 'nh' не найдена. Убедитесь, что она установлена.")
        return None


def parse_switches(output):
    """Парсит вывод nh os info и извлекает информацию о переключениях"""
    switches = defaultdict(int)

    # Паттерн для поиска дат в формате YYYY-MM-DD или подобном
    # Адаптируйте под реальный формат вывода nh os info
    date_pattern = re.compile(r"(\d{4}-\d{2}-\d{2})")

    for line in output.split("\n"):
        match = date_pattern.search(line)
        if match:
            date = match.group(1)
            switches[date] += 1

    return switches


def display_statistics(switches):
    """Отображает статистику с красивым форматированием"""
    console = Console()

    if not switches:
        console.print(
            Panel(
                "[yellow]Переключений не найдено в выводе[/yellow]",
                title="[bold red]Статистика[/bold red]",
                border_style="red",
            )
        )
        return

    # Создаем таблицу
    table = Table(
        title="[bold cyan]📊 Статистика переключений NixOS[/bold cyan]",
        show_header=True,
        header_style="bold magenta",
        border_style="blue",
        title_style="bold white on blue",
    )

    table.add_column("Дата", style="cyan", justify="center")
    table.add_column("Количество", style="green", justify="center")
    table.add_column("Визуализация", style="yellow")

    # Сортируем по дате
    sorted_dates = sorted(switches.keys(), reverse=True)

    max_count = max(switches.values()) if switches else 1

    for date in sorted_dates:
        count = switches[date]
        # Создаем визуализацию
        bar_length = int((count / max_count) * 30)
        bar = "█" * bar_length

        # Раскрашиваем в зависимости от количества
        if count > 5:
            count_style = "[bold red]"
        elif count > 2:
            count_style = "[bold yellow]"
        else:
            count_style = "[bold green]"

        table.add_row(date, f"{count_style}{count}[/]", f"[yellow]{bar}[/]")

    console.print(table)

    # Общая статистика
    total = sum(switches.values())
    unique_days = len(switches)
    avg = total / unique_days if unique_days > 0 else 0

    summary = Text()
    summary.append("📈 Общая статистика:\n", style="bold white")
    summary.append(f"  • Всего переключений: ", style="cyan")
    summary.append(f"{total}\n", style="bold green")
    summary.append(f"  • Уникальных дней: ", style="cyan")
    summary.append(f"{unique_days}\n", style="bold green")
    summary.append(f"  • Среднее в день: ", style="cyan")
    summary.append(f"{avg:.1f}\n", style="bold yellow")

    console.print(Panel(summary, title="[bold]Итого[/bold]", border_style="green"))


def main():
    console = Console()
    console.print("[bold blue]Запуск анализа nh os info...[/bold blue]\n")

    output = get_nh_info()
    if output is None:
        return

    switches = parse_switches(output)
    display_statistics(switches)


if __name__ == "__main__":
    main()
