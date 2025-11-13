SELECT
    c.Coach AS Coach,
    SUM(CASE WHEN p.Place = 1 THEN 3
             WHEN p.Place = 2 THEN 2
             WHEN p.Place = 3 THEN 1
        ELSE 0 END) AS RatingSum
FROM SwimCompetitions2021 AS c
JOIN SwimResults AS p ON c.CompetitionID = p.CompetitionID
GROUP BY c.Coach
ORDER BY RatingSum DESC
LIMIT 10;

Понял! Теги и номера находятся в одном логическом блоке/сообщении. Вот исправленный скрипт:

```python
import re
import csv
import sys

def parse_log_blocks(log_file, tags):
    """
    Парсит лог, находя блоки сообщений где есть и тег и номер телефона.
    Собирает данные в пределах одного логического блока.
    """
    seen = set()
    results = []
    
    phone_pattern = re.compile(
        r'(\+?7|8)?\s*[\(\-\s]*\d{3}[\)\-\s]*\d{3}[\-\s]?\d{2}[\-\s]?\d{2}'
    )
    
    try:
        with open(log_file, 'r', encoding='utf-8') as f:
            current_block = []  # Текущий блок сообщения
            current_phone = None
            current_tag = None
            current_content = []
            
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                
                # Если пустая строка - заканчиваем текущий блок
                if not line and current_block:
                    # Обрабатываем собранный блок
                    block_text = ' '.join(current_block)
                    
                    # Ищем телефон во всем блоке
                    phone_match = phone_pattern.search(block_text)
                    if phone_match:
                        phone_number = phone_match.group().strip()
                        
                        # Ищем теги во всем блоке
                        for tag in tags:
                            if tag.lower() in block_text.lower():
                                # Извлекаем содержимое связанное с тегом
                                tag_index = block_text.lower().find(tag.lower())
                                content_start = tag_index + len(tag)
                                content = block_text[content_start:].strip()
                                content = re.sub(r'^[\s:\-\"]+', '', content)
                                
                                if content:
                                    unique_key = (tag.lower(), content.lower(), phone_number)
                                    
                                    if unique_key not in seen:
                                        seen.add(unique_key)
                                        results.append((tag, content, phone_number, line_num))
                    
                    # Сбрасываем блок
                    current_block = []
                    current_phone = None
                    current_tag = None
                    current_content = []
                
                elif line:
                    # Добавляем строку в текущий блок
                    current_block.append(line)
            
            # Обрабатываем последний блок если файл не заканчивается пустой строкой
            if current_block:
                block_text = ' '.join(current_block)
                phone_match = phone_pattern.search(block_text)
                if phone_match:
                    phone_number = phone_match.group().strip()
                    
                    for tag in tags:
                        if tag.lower() in block_text.lower():
                            tag_index = block_text.lower().find(tag.lower())
                            content_start = tag_index + len(tag)
                            content = block_text[content_start:].strip()
                            content = re.sub(r'^[\s:\-\"]+', '', content)
                            
                            if content:
                                unique_key = (tag.lower(), content.lower(), phone_number)
                                
                                if unique_key not in seen:
                                    seen.add(unique_key)
                                    results.append((tag, content, phone_number, line_num))
    
    except Exception as e:
        print(f"Ошибка: {e}")
        return []
    
    return results

def main():
    if len(sys.argv) < 3:
        print("Использование: python script.py <лог_файл> <тег1> [тег2 ...]")
        print("Пример: python script.py app.log SMS ERROR")
        print("Поиск по блокам сообщений - соберет номер и текст из одного блока")
        sys.exit(1)
    
    log_file = sys.argv[1]
    tags = sys.argv[2:]
    
    print(f"Анализ блоков в файле: {log_file}")
    print(f"Ищем теги: {', '.join(tags)}")
    print("Обработка...")
    
    results = parse_log_blocks(log_file, tags)
    
    if not results:
        print("Записей не найдено")
        return
    
    # Экспорт в CSV
    output_file = f"blocks_{log_file.replace('.', '_')}.csv"
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Тег', 'Текст сообщения', 'Номер телефона', 'Строка'])
        writer.writerows(results)
    
    print(f"Найдено: {len(results)} уникальных записей")
    print(f"Сохранено в: {output_file}")
    
    # Статистика по тегам
    tag_stats = {}
    for tag, content, phone, line_num in results:
        tag_stats[tag] = tag_stats.get(tag, 0) + 1
    
    print("\nСтатистика по тегам:")
    for tag, count in tag_stats.items():
        print(f"  {tag}: {count} записей")
    
    # Примеры
    print("\nПримеры найденных записей:")
    for tag, content, phone, line_num in results[:3]:
        content_preview = content[:80] + "..." if len(content) > 80 else content
        print(f"  [{tag}] Телефон: {phone}")
        print(f"  Текст: {content_preview}")
        print()

if __name__ == "__main__":
    main()
```

Ключевые особенности:

1. Работа с блоками - собирает многострочные сообщения в логические блоки
2. Соотнесение данных - номер телефона и текст берутся из одного блока
3. Разделение по пустым строкам - блоки разделяются пустыми строками
4. Уникальность - проверка дубликатов по комбинации (тег + текст + номер)

Как работает:

· Читает лог построчно
· Собирает последовательные непустые строки в блок
· Когда встречает пустую строку - обрабатывает собранный блок
· В блоке ищет номер телефона и указанные теги
· Соотносит номер с текстом из того же блока

Использование:

```bash
python script.py app.log SMS
python script.py app.log ERROR WARNING
```

Теперь скрипт будет правильно находить номера телефонов и соотносить их с текстом из одного логического блока сообщения!