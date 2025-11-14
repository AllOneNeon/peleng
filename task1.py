class First:
    def getClassname(self):
        return "First"
    
    def getLetter(self):
        return "A"

class Second:
    def getClassname(self):
        return "Second"
    
    def getLetter(self):
        return "B"

first_obj = First()
second_obj = Second()

print(first_obj.getClassname())
print(second_obj.getClassname())
print(first_obj.getLetter())  
print(second_obj.getLetter())


Вот скрипт для проверки CSV файла на дубликаты:

```python
import csv
from typing import List, Set
from collections import Counter

def check_csv_for_duplicates(csv_file_path: str):
    """
    Проверяет CSV файл на наличие дубликатов телефонных номеров.
    """
    print("=" * 50)
    print("Проверка CSV файла на дубликаты")
    print("=" * 50)
    
    try:
        with open(csv_file_path, 'r', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile)
            
            # Пропускаем заголовок
            header = next(reader, None)
            if header:
                print(f"Заголовок: {header}")
            
            # Читаем все номера
            all_numbers = []
            for row in reader:
                if row:  # Проверяем, что строка не пустая
                    all_numbers.append(row[0].strip())
            
            print(f"Всего номеров в CSV: {len(all_numbers)}")
            
            # Проверяем уникальность через set
            unique_numbers = set(all_numbers)
            print(f"Уникальных номеров: {len(unique_numbers)}")
            
            if len(all_numbers) == len(unique_numbers):
                print("✅ ДУБЛИКАТОВ НЕ НАЙДЕНО! Все номера уникальны.")
            else:
                duplicates_count = len(all_numbers) - len(unique_numbers)
                print(f"⚠️ НАЙДЕНО ДУБЛИКАТОВ: {duplicates_count}")
                
                # Находим конкретные дубликаты
                counter = Counter(all_numbers)
                duplicates = {number: count for number, count in counter.items() if count > 1}
                
                print("\nПовторяющиеся номера:")
                for number, count in list(duplicates.items())[:10]:  # Показываем первые 10
                    print(f"  {number} - повторяется {count} раз")
                
                if len(duplicates) > 10:
                    print(f"  ... и еще {len(duplicates) - 10} дубликатов")
                
    except FileNotFoundError:
        print(f"❌ Файл {csv_file_path} не найден!")
    except Exception as e:
        print(f"❌ Ошибка при чтении файла: {e}")

def main():
    """
    Основная функция для проверки CSV файла.
    """
    csv_file_path = input("Введите путь к CSV файлу (или нажмите Enter для phones.csv): ").strip()
    
    if not csv_file_path:
        csv_file_path = "phones.csv"
    
    check_csv_for_duplicates(csv_file_path)

if __name__ == "__main__":
    main()
```

Также версия с аргументами командной строки:

```python
import csv
import argparse
from typing import List, Set
from collections import Counter

def check_csv_for_duplicates(csv_file_path: str):
    """
    Проверяет CSV файл на наличие дубликатов телефонных номеров.
    """
    print("=" * 50)
    print("Проверка CSV файла на дубликаты")
    print("=" * 50)
    
    try:
        with open(csv_file_path, 'r', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile)
            
            # Пропускаем заголовок
            header = next(reader, None)
            if header:
                print(f"Заголовок: {header}")
            
            # Читаем все номера
            all_numbers = []
            for row in reader:
                if row:  # Проверяем, что строка не пустая
                    all_numbers.append(row[0].strip())
            
            print(f"Всего номеров в CSV: {len(all_numbers)}")
            
            # Проверяем уникальность через set
            unique_numbers = set(all_numbers)
            print(f"Уникальных номеров: {len(unique_numbers)}")
            
            if len(all_numbers) == len(unique_numbers):
                print("✅ ДУБЛИКАТОВ НЕ НАЙДЕНО! Все номера уникальны.")
                return True
            else:
                duplicates_count = len(all_numbers) - len(unique_numbers)
                print(f"⚠️ НАЙДЕНО ДУБЛИКАТОВ: {duplicates_count}")
                
                # Находим конкретные дубликаты
                counter = Counter(all_numbers)
                duplicates = {number: count for number, count in counter.items() if count > 1}
                
                print(f"\nВсего повторяющихся номеров: {len(duplicates)}")
                print("\nПервые 10 повторяющихся номеров:")
                for number, count in list(duplicates.items())[:10]:
                    print(f"  {number} - повторяется {count} раз")
                
                if len(duplicates) > 10:
                    print(f"  ... и еще {len(duplicates) - 10} дубликатов")
                
                return False
                
    except FileNotFoundError:
        print(f"❌ Файл {csv_file_path} не найден!")
        return False
    except Exception as e:
        print(f"❌ Ошибка при чтении файла: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Проверка CSV файла на дубликаты телефонных номеров')
    parser.add_argument('--file', '-f', default='phones.csv', 
                       help='Путь к CSV файлу (по умолчанию phones.csv)')
    
    args = parser.parse_args()
    
    check_csv_for_duplicates(args.file)

if __name__ == "__main__":
    main()
```

Как использовать:

Простая версия (с вводом пути):

```bash
python check_duplicates.py
```

Расширенная версия (с аргументами):

```bash
python check_duplicates.py --file "phones.csv"
# или
python check_duplicates.py -f "D:\лог\phones.csv"
```

Что скрипт покажет:

· Общее количество номеров в CSV
· Количество уникальных номеров
· Если есть дубли - покажет какие именно и сколько раз повторяются
· ✅ Если дублей нет - сообщит об этом

Это 100% гарантированная проверка того, что в CSV нет дубликатов!
