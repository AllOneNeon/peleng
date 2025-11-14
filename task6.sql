CREATE PROCEDURE FindWinnersByCompetitionOrYear
    @CompetitionName NVARCHAR(100) = NULL,
    @YearComp INT = NULL
AS
BEGIN
    SELECT FullName, LastName, CompetitionName, YearComp, PlaceComp 
    FROM SwimCompetitions2021 
    WHERE (CompetitionName = @CompetitionName OR @CompetitionName IS NULL)
      AND (YearComp = @YearComp OR @YearComp IS NULL)
      AND PlaceComp IN (1, 2, 3)
END;

Понял! Нужно искать номера между фразой !!!! Message phone: и запятой ,.

Вот переделанный скрипт:

```python
import os
import re
import csv
import argparse
from typing import Set, List, Tuple
from datetime import datetime

class PhoneExtractor:
    def __init__(self):
        self.processed_files = 0
        self.total_phones = 0
        
    def extract_phones_optimized(self, file_path: str) -> Set[str]:
        """
        Извлекает телефонные номера между фразой '!!!! Message phone:' и запятой ','
        """
        phones = set()
        
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
                
                # Ищем номера между фразой '!!!! Message phone:' и запятой ','
                pattern = r'!!!! Message phone:\s*([^,]+),'
                
                matches = re.findall(pattern, content, re.IGNORECASE)
                for match in matches:
                    phone = match.strip()
                    if phone:
                        phones.add(phone)
        
        except UnicodeDecodeError:
            return self._try_alternative_encodings(file_path)
        except Exception as e:
            print(f"Ошибка при обработке {file_path}: {e}")
            
        return phones
    
    def _try_alternative_encodings(self, file_path: str) -> Set[str]:
        """Пробует разные кодировки для чтения файла."""
        encodings = ['cp1251', 'latin1', 'iso-8859-1', 'windows-1252']
        
        for encoding in encodings:
            try:
                phones = set()
                with open(file_path, 'r', encoding=encoding) as file:
                    content = file.read()
                    
                    # Тот же паттерн для альтернативных кодировок
                    pattern = r'!!!! Message phone:\s*([^,]+),'
                    
                    matches = re.findall(pattern, content, re.IGNORECASE)
                    for match in matches:
                        phone = match.strip()
                        if phone:
                            phones.add(phone)
                return phones
            except:
                continue
        
        print(f"Не удалось прочитать файл {file_path} с доступными кодировками")
        return set()
    
    def process_directory(self, directory: str, file_pattern: str = None) -> Tuple[Set[str], int]:
        """
        Обрабатывает все файлы в директории.
        """
        all_phones = set()
        processed_count = 0
        
        try:
            for filename in os.listdir(directory):
                file_path = os.path.join(directory, filename)
                
                if os.path.isfile(file_path):
                    if file_pattern and not re.match(file_pattern.replace('*', '.*'), filename):
                        continue
                    
                    phones = self.extract_phones_optimized(file_path)
                    all_phones.update(phones)
                    processed_count += 1
                    
                    if phones:
                        print(f"✓ {filename}: найдено {len(phones)} номеров")
                    else:
                        print(f"  {filename}: номера не найдены")
                        
        except Exception as e:
            print(f"Ошибка при обработке директории {directory}: {e}")
        
        self.processed_files = processed_count
        self.total_phones = len(all_phones)
        
        return all_phones, processed_count

def main():
    parser = argparse.ArgumentParser(description='Извлечение телефонных номеров из лог-файлов')
    parser.add_argument('--directory', '-d', default='.', 
                       help='Директория с лог-файлами (по умолчанию текущая)')
    parser.add_argument('--output', '-o', default='phones.csv',
                       help='Имя выходного CSV файла')
    parser.add_argument('--pattern', '-p', 
                       help='Шаблон файлов (например, "*.log")')
    
    args = parser.parse_args()
    
    print("=" * 50)
    print("Phone Number Extractor")
    print("=" * 50)
    print("Поиск по шаблону: '!!!! Message phone: [номер],'")
    
    start_time = datetime.now()
    extractor = PhoneExtractor()
    
    print(f"Директория: {os.path.abspath(args.directory)}")
    if args.pattern:
        print(f"Шаблон файлов: {args.pattern}")
    print("-" * 50)
    
    # Обрабатываем файлы
    all_phones, file_count = extractor.process_directory(args.directory, args.pattern)
    
    # Сохраняем результаты
    if all_phones:
        try:
            with open(args.output, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(['Phone Number'])
                
                # Сортируем и сохраняем номера как есть
                for phone in sorted(all_phones):
                    writer.writerow([phone])
            
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            
            print("-" * 50)
            print("РЕЗУЛЬТАТЫ:")
            print(f"Обработано файлов: {file_count}")
            print(f"Найдено уникальных номеров: {len(all_phones)}")
            print(f"Время выполнения: {duration:.2f} секунд")
            print(f"Результат сохранен в: {args.output}")
            print("ПРИМЕЧАНИЕ: При открытии в Excel установите формат ячеек как 'Текст'")
            
        except Exception as e:
            print(f"Ошибка при сохранении результатов: {e}")
    else:
        print("Телефонные номера не найдены.")

if __name__ == "__main__":
    main()
```

Что изменилось:

· Теперь ищет по шаблону: !!!! Message phone: [номер],
· Извлекает всё что между фразой и запятой
· Удаляет пробелы вокруг номера
· Все дубликаты автоматически удаляются через set()

Запуск:

```bash
python phone_extractor.py -d "D:\лог" -p "*.log" -o "phones.csv"
```

Скрипт найдет все номера после фразы !!!! Message phone: и до запятой, удалит все дубли и экспортирует в CSV.