# 1C Metadata DevOps Pipeline (Vibe Coding)

## Статус: (Assembly Successful) 
Нам удалось успешно автоматизировать инъекцию новых объектов в иерархический XML-дамп 1С (v2.18) без использования Конфигуратора.

## Технология: Genetic Cloning (V22)
1. **Топологическая точность:** Объекты вставляются в Configuration.xml и ConfigDumpInfo.xml строго в свои группы (после последнего соседа того же типа).
2. **UUID Mapping:** Полное перестроение карты UUID внутри InternalInfo (TypeId, ValueId), что исключает коллизии типов.
3. **Prefix Agnostic:** XPath-запросы работают через local-name(), игнорируя нестабильность пространств имен.
4. **Total Recall:** Глобальная замена внутренних ссылок внутри XML объекта.

## План развития
- [x] Инъекция Справочника (базовый клон)
- [ ] Добавление реквизитов (Attributes)
- [ ] Добавление форм (Descriptor + XML + BSL)
- [ ] Добавление команд (Command + BSL)
- [ ] Масштабирование на классы: Documents, Registers, BusinessProcesses
