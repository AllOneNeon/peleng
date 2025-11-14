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


Вот оптимальный и безопасный скрипт для извлечения уникальных телефонных номеров из лог-файлов:

```python
import os
import re
import csv
from typing import Set, List

def extract_phones_from_file(file_path: str) -> Set[str]:
    """
    Извлекает уникальные телефонные номера из одного файла.
    
    Args:
        file_path: Путь к файлу для обработки
        
    Returns:
        Множество уникальных телефонных номеров
    """
    phones = set()
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
            
            # Используем регулярное выражение для поиска тегов <phone>
            # re.DOTALL позволяет .匹配任何字符, включая переносы строк
            pattern = r'<phone>(.*?)</phone>'
            matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
            
            for match in matches:
                # Очищаем номер от лишних пробелов и переносов строк
                phone = match.strip()
                if phone:  # Проверяем, что номер не пустой
                    phones.add(phone)
                    
    except UnicodeDecodeError:
        # Если UTF-8 не сработал, пробуем другие кодировки
        try:
            with open(file_path, 'r', encoding='cp1251') as file:
                content = file.read()
                pattern = r'<phone>(.*?)</phone>'
                matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
                
                for match in matches:
                    phone = match.strip()
                    if phone:
                        phones.add(phone)
        except Exception as e:
            print(f"Ошибка при чтении файла {file_path}: {e}")
            
    except Exception as e:
        print(f"Ошибка при обработке файла {file_path}: {e}")
    
    return phones

def find_log_files(directory: str = '.') -> List[str]:
    """
    Находит все файлы логов в указанной директории.
    
    Args:
        directory: Директория для поиска (по умолчанию текущая)
        
    Returns:
        Список путей к файлам логов
    """
    log_files = []
    
    try:
        for filename in os.listdir(directory):
            file_path = os.path.join(directory, filename)
            if os.path.isfile(file_path):
                log_files.append(file_path)
    except Exception as e:
        print(f"Ошибка при поиске файлов в {directory}: {e}")
    
    return log_files

def save_phones_to_csv(phones: Set[str], output_file: str = 'phones.csv'):
    """
    Сохраняет телефонные номера в CSV файл.
    
    Args:
        phones: Множество телефонных номеров
        output_file: Имя выходного CSV файла
    """
    try:
        with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['Phone Number'])  # Заголовок
            
            # Сортируем номера для удобства
            sorted_phones = sorted(phones)
            for phone in sorted_phones:
                writer.writerow([phone])
                
        print(f"Успешно сохранено {len(phones)} уникальных номеров в {output_file}")
        
    except Exception as e:
        print(f"Ошибка при сохранении в CSV: {e}")

def main():
    """Основная функция скрипта."""
    print("Запуск обработки лог-файлов...")
    
    # Находим все файлы в текущей директории
    log_files = find_log_files()
    
    if not log_files:
        print("Файлы не найдены в текущей директории.")
        return
    
    print(f"Найдено {len(log_files)} файлов для обработки.")
    
    # Собираем все уникальные номера
    all_phones = set()
    
    for file_path in log_files:
        print(f"Обработка: {os.path.basename(file_path)}")
        file_phones = extract_phones_from_file(file_path)
        all_phones.update(file_phones)
        print(f"  Найдено номеров в файле: {len(file_phones)}")
    
    # Сохраняем результаты
    if all_phones:
        save_phones_to_csv(all_phones)
        print(f"\nИтого найдено уникальных телефонных номеров: {len(all_phones)}")
    else:
        print("Телефонные номены не найдены.")

if __name__ == "__main__":
    main()
```

Также вот улучшенная версия с дополнительными возможностями:

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
        Оптимизированная версия извлечения телефонов - читает файл построчно.
        Эффективнее для больших файлов.
        """
        phones = set()
        in_phone_tag = False
        phone_content = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                for line in file:
                    # Ищем начало тега
                    start_match = re.search(r'<phone>', line, re.IGNORECASE)
                    if start_match:
                        in_phone_tag = True
                        # Берем часть строки после <phone>
                        content_start = start_match.end()
                        phone_content.append(line[content_start:])
                        continue
                    
                    # Если внутри тега, ищем конец тега
                    if in_phone_tag:
                        end_match = re.search(r'</phone>', line, re.IGNORECASE)
                        if end_match:
                            # Берем часть строки до </phone>
                            content_end = end_match.start()
                            phone_content.append(line[:content_end])
                            
                            # Собираем полный номер
                            full_phone = ''.join(phone_content).strip()
                            if full_phone:
                                phones.add(full_phone)
                            
                            # Сбрасываем состояние
                            in_phone_tag = False
                            phone_content = []
                        else:
                            # Весь текст между тегами
                            phone_content.append(line)
        
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
                    pattern = r'<phone>(.*?)</phone>'
                    matches = re.findall(pattern, content, re.DOTALL | re.IGNORECASE)
                    
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
        
        Args:
            directory: Путь к директории
            file_pattern: Шаблон для фильтрации файлов (например, '*.log')
            
        Returns:
            Кортеж (множество номеров, количество обработанных файлов)
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
            
        except Exception as e:
            print(f"Ошибка при сохранении результатов: {e}")
    else:
        print("Телефонные номера не найдены.")

if __name__ == "__main__":
    main()
```

Особенности скрипта:

1. Безопасность: Обработка ошибок чтения файлов, поддержка разных кодировок
2. Оптимальность:
   · Использует множества для автоматического удаления дубликатов
   · Построчное чтение для больших файлов
   · Эффективные регулярные выражения
3. Гибкость:
   · Поддержка аргументов командной строки
   · Фильтрация файлов по шаблону
   · Работа с разными кодировками
4. Отчетность: Детальный вывод процесса и результатов

Использование:

```bash
# Базовая версия
python phone_extractor.py

# Расширенная версия
python phone_extractor_advanced.py --directory ./logs --pattern "*.log" --output results.csv
```

Скрипт эффективно обработает 45+ файлов и гарантирует отсутствие дубликатов в результате.