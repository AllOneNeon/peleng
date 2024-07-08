import re


file_paths = """***/Test/files/1.xls, ***/Test/files/2.XLSX,***/Test/files/9.vra, ***/Test/files/3.jpg, ***/Test/files/4.xml,
 ***/Test/files/5.png, ***/Test/files/6.xlsm, ***/Test/files/7.xlso, ***/Test/files/8.xls*,
***/Test/files/9.xlasx, ***/Test/files/9.vba"""

excel_formats = re.findall(r'\b\w+\.(xls[xm]?)\b', file_paths, flags=re.IGNORECASE)
file_names_and_paths = re.findall(r'\*\*\*/(Test/files/\w+\.\w+)', file_paths)

print("Форматы файлов Excel:")
for fmt, name_path in zip(excel_formats, file_names_and_paths):
    print(f"Формат: {fmt}, Название: {name_path.split('/')[-1]}, Путь: {name_path}")