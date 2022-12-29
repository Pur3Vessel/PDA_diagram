# Распределение задач
Баев Данил ([pur3vessel](https://github.com/Pur3Vessel)) - построение грамматики, парсер.

Федоров Александр ([JazZzik](https://github.com/JazZzik)) - структура автомата, визуализация.
# Грамматика
(Это потом должно пойти в отчет)

Стартовый нетерминал: [automata]
- [automata] -> [initial-state][states][sep][transitions] | [initial-state][sep][transitions]
- [initial-state] -> [state-name] | [state-name]-[flag]
- [states] -> [state],[states] | [state] 
- [state] -> [state-name] | [state-name]-[flag]
- [state-name] -> [symbol] | [symbol][state-name]
- [transitions] -> [transiton] | [transiton][sep][transitions]
- [transition] -> [before][trans-sep][after] | [state-name],[alphabet-symbol],[stack-any][trans-sep][state-name],[stack-any]
- [transition] -> [state-name],[alphabet-symbol],[stack-bottom][trans-sep][state-name],[stack-symbols][stack-bottom]
- [before] -> [state-name], [alphabet-symbol], [stack-symbol] | [state-name], [alphabet-symbol], [stack-any] 
- [after] -> [state-name], [stack-symbols] | [state-name], [empty] 
- [alphabet-symbol] -> [al-sym] | [empty]
- [stack-symbols] -> [stack-symbol][stack-symbols] | [stack-symbol]

[symbol] - символ в имени состояния. Может быть любым разрешенным символом.

Параметры:
- [al-sym] - символ входного алфавита. Задается в config некоторой регуляркой (по умолчанию: [a-z])
- [stack-symbol] - символ стэкового алфавита. Задается в config некоторой регуляркой (по умолчанию: [A-Y])
- [flag] - строка, которая задает метку завершающего состояния. По умолчанию: final
- [sep] - символ, который задает разделитель между "строками". По умолчанию: ;
- [trans-sep] - строка, которая задает разделитель между двумя частями правила. По умолчанию: ->
- [empty] - символ, который задает пустую строку. По умолчанию: ɛ
- [stack-any] - символ, который задает любой стэковый символ. По умолчанию: *
- [stack-bottom] - символ, который задает дно стэка. Не должен распознаваться регуляркой, задающей стэковый алфафит. По умолчанию: Z

Ограничения:
- Имена состояний, которые записываются в описании переходов, должны быть объявлены в [states] 
- В [symbol] запрещено использовать символы токенов, а также символы , и - и пробельные символы

(Метки ловушек, недетерминированных переходов и stack-independent переходов будут расставляться при визуализации)
# Как заполнять config
Параметры указываются через запятую в формате [имя параметра] значение

Пример: [trans-sep] ::=, [empty] !

В случае, если имя параметра указано неверно, этот параметр не будет изменен. Если параметр будет параметризирован более одного раза, то считаться будет только последнее упоминание.

Ограничения:
- Нельзя в качестве параметров использовать запятую 
- Для избежания неоднозначности все токены должны быть уникальными значениями
- Нельзя параметризировать токены пробельными символами
# Запуск программы