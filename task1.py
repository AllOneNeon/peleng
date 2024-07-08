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