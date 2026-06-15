# UML-диаграммы для A11y Inspector

Ниже - набор UML-диаграмм в формате PlantUML для проекта "Инспектор доступности".
Проект представляет собой Chromium-расширение Manifest V3, которое запускает проверку доступности страницы, анализирует DOM в изолированной вкладке и формирует отчёт в выбранном формате.

---

## 1. Диаграмма вариантов использования

```plantuml
@startuml
left to right direction

actor "Пользователь" as User
actor "Проверяемый сайт" as Website
actor "Chromium API" as Chrome
actor "Doka Guide" as Doka

rectangle "Инспектор доступности" {
  usecase "Открыть popup\nрасширения" as UC_OpenPopup
  usecase "Автоматически подставить\nURL активной вкладки" as UC_AutoUrl
  usecase "Ввести URL сайта" as UC_EnterUrl
  usecase "Выбрать формат\nотчёта" as UC_SelectFormat
  usecase "Запустить проверку\nдоступности" as UC_StartCheck
  usecase "Проверить корректность\nURL" as UC_ValidateUrl
  usecase "Открыть скрытую вкладку\nдля анализа" as UC_OpenTab
  usecase "Внедрить content script\nи утилиты" as UC_InjectScripts
  usecase "Проанализировать DOM\nстраницы" as UC_AnalyzeDom
  usecase "Проверить контраст,\nсемантику, формы и ARIA" as UC_RunRules
  usecase "Сформировать сводку\nошибок и предупреждений" as UC_BuildSummary
  usecase "Сгенерировать отчёт\nJSON/HTML/Text/Markdown" as UC_GenerateReport
  usecase "Показать результаты\nв popup" as UC_ShowResults
  usecase "Скачать отчёт" as UC_Download
  usecase "Скопировать отчёт\nв буфер обмена" as UC_Copy
  usecase "Открыть предпросмотр\nотчёта" as UC_Preview
  usecase "Фильтровать проблемы\nв предпросмотре" as UC_Filter
  usecase "Получить ссылки\nна материалы Doka" as UC_GuideLinks
}

User --> UC_OpenPopup
User --> UC_EnterUrl
User --> UC_SelectFormat
User --> UC_StartCheck
User --> UC_Download
User --> UC_Copy
User --> UC_Preview
User --> UC_Filter

UC_OpenPopup --> UC_AutoUrl : <<include>>
UC_StartCheck --> UC_ValidateUrl : <<include>>
UC_StartCheck --> UC_OpenTab : <<include>>
UC_StartCheck --> UC_InjectScripts : <<include>>
UC_StartCheck --> UC_AnalyzeDom : <<include>>
UC_AnalyzeDom --> UC_RunRules : <<include>>
UC_AnalyzeDom --> UC_BuildSummary : <<include>>
UC_StartCheck --> UC_GenerateReport : <<include>>
UC_StartCheck --> UC_ShowResults : <<include>>
UC_GenerateReport --> UC_GuideLinks : <<include>>
UC_Preview --> UC_Filter : <<extend>>

Chrome --> UC_AutoUrl
Chrome --> UC_OpenTab
Chrome --> UC_InjectScripts
Website --> UC_AnalyzeDom
Doka --> UC_GuideLinks
@enduml
```

---

## 2. Диаграмма классов и модулей

```plantuml
@startuml
skinparam classAttributeIconSize 0

class PopupController {
  -currentReport: Object
  -currentFormat: string
  +init()
  +startCheck()
  +handleResponse(response)
  +displayResults(report, format)
  +downloadReport()
  +copyReportToClipboard()
  +openReportAsWindow(reportData, format)
}

class BackgroundServiceWorker {
  +handleAccessibilityCheck(url, format)
  +waitForTabLoad(tabId)
  +waitForContentScript(tabId)
  +performAccessibilityCheck()
  +generateReportInContentScript(data, format)
  +isValidHttpUrl(value)
}

class ContentScript {
  +initializeDependencies()
  +runA11yChecks()
  +runBasicChecks()
  +checkColorContrast()
  +checkNonTextContrast()
  +checkKeyboardNavigation()
  +checkSemanticMarkup()
  +checkAriaAttributes()
  +checkLanguage()
}

class A11yRuleUtils {
  +runAllChecks()
  +isElementVisible(element)
  +getSelector(element)
}

class A11yRules {
  +checkImages()
  +checkForms()
  +checkLinks()
  +checkHeadings()
  +checkButtons()
}

class ColorUtils {
  +parseColor(color)
  +getLuminance(color)
  +calculateContrastRatio(color1, color2)
  +suggestContrastImprovements(color, background)
  +simulateColorBlindness(color, type)
}

class LanguageDetector {
  +detectLanguage(text)
  +detectMixedLanguage(text)
}

class ReportGenerator {
  +generate(data, format)
  +generateJSON(data)
  +generateHTML(data)
  +generateText(data)
  +enrichWithGuideLinks(data)
  +getGuideLinks(issue)
}

class ReportPreviewController {
  +init(reportData)
  +showDetailsIssues(issues)
  +initSelectorsForSorting(issues)
  +downloadAsHTML(reportData)
  +downloadAsJSON(reportData)
  +downloadAsMARKDOWN(reportData)
}

class AccessibilityReport {
  +url: string
  +timestamp: string
  +issues: Issue[]
  +summary: Summary
}

class Issue {
  +type: IssueType
  +category: IssueCategory
  +message: string
  +selector: string
  +element: string
  +details: Object
  +guideLinks: GuideLink[]
}

class Summary {
  +total: number
  +errors: number
  +warnings: number
}

class GuideLink {
  +title: string
  +url: string
}

enum IssueType {
  error
  warning
}

enum ReportFormat {
  json
  html
  text
  markdown
}

PopupController --> BackgroundServiceWorker : chrome.runtime.sendMessage()
BackgroundServiceWorker --> ContentScript : chrome.scripting.executeScript()
ContentScript --> A11yRuleUtils : запускает общие правила
A11yRuleUtils --> A11yRules : использует набор правил
ContentScript --> ColorUtils : расчёт контраста
ContentScript --> LanguageDetector : проверка языка
BackgroundServiceWorker --> ReportGenerator : формирует отчёт
ReportGenerator --> AccessibilityReport
AccessibilityReport "1" *-- "0..*" Issue
AccessibilityReport "1" *-- "1" Summary
Issue "1" o-- "0..*" GuideLink
ReportPreviewController --> AccessibilityReport : отображает и фильтрует
PopupController --> ReportPreviewController : открывает окно отчёта
Issue --> IssueType
PopupController --> ReportFormat
@enduml
```

---

## 3. Диаграмма компонентов

```plantuml
@startuml
skinparam componentStyle rectangle

actor "Пользователь" as User

package "Chromium Extension MV3" {
  [manifest.json] as Manifest
  [Popup UI\npopup.html/css/js] as Popup
  [Report Preview\nreport-popup.html/css/js] as Preview
  [Background Service Worker\nbackground.js] as Background
  [Content Script\ncontent-script.js] as Content
  [A11y Rules\nutils/a11y-rules.js] as Rules
  [Color Utils\nutils/color-utils.js] as Color
  [Language Detector\nutils/language-detector.js] as Lang
  [Report Generator\nutils/report-generator.js] as Generator
  [Doka Links\nutils/doka-links.js] as DokaLinks
  database "chrome.storage.local" as Storage
}

cloud "Проверяемая web-страница" as Page
component "Chrome Tabs API" as TabsApi
component "Chrome Scripting API" as ScriptingApi
component "Clipboard API" as Clipboard

User --> Popup : ввод URL,\nвыбор формата
Popup --> Storage : сохранить lastUrl,\nlastFormat
Popup --> Background : checkAccessibility
Popup --> Preview : открыть отчёт
Popup --> Clipboard : скопировать отчёт

Background --> TabsApi : создать/закрыть\nскрытую вкладку
Background --> ScriptingApi : внедрить scripts\nи выполнить функции
ScriptingApi --> Content
Content --> Page : анализ DOM
Content --> Rules
Content --> Color
Content --> Lang
Background --> Generator : generate(data, format)
Generator --> DokaLinks : добавить справочные ссылки
Preview --> Storage : получить currentReport

Manifest ..> Popup : default_popup
Manifest ..> Background : service_worker
Manifest ..> Content : content_scripts
@enduml
```

---

## 4. Диаграмма последовательности: проверка доступности сайта

```plantuml
@startuml
actor "Пользователь" as User
participant "Popup UI" as Popup
participant "chrome.storage.local" as Storage
participant "Background\nservice worker" as Background
participant "Chrome Tabs API" as Tabs
participant "Chrome Scripting API" as Scripting
participant "Content Script" as Content
participant "A11yRuleUtils\nи спецпроверки" as Rules
participant "ReportGenerator" as Generator

User -> Popup: Открывает расширение
Popup -> Storage: Получить lastUrl и lastFormat
Storage --> Popup: Сохранённые значения
Popup -> Tabs: Запросить активную вкладку
Tabs --> Popup: URL текущей страницы

User -> Popup: Нажимает "Проверить доступность"
Popup -> Popup: Проверить URL и формат
Popup -> Storage: Сохранить lastUrl и lastFormat
Popup -> Background: checkAccessibility(url, format)

Background -> Background: isValidHttpUrl(url)
Background -> Tabs: Создать неактивную вкладку
Tabs --> Background: tabId
Background -> Tabs: Дождаться status = complete

Background -> Scripting: Внедрить utils и content-script.js
Scripting -> Content: Инициализация зависимостей
Content --> Scripting: window.a11yInspectorReady = true
Background -> Scripting: Проверить готовность зависимостей
Scripting --> Background: runA11yChecks, ColorUtils,\nA11yRules, ReportGenerator доступны

Background -> Scripting: Выполнить performAccessibilityCheck()
Scripting -> Content: runA11yChecks()
Content -> Rules: runAllChecks()
Rules --> Content: Базовые проблемы доступности
Content -> Content: Выполнить спецпроверки\nконтраста, ARIA, форм, языка
Content --> Scripting: AccessibilityReport
Scripting --> Background: issues и summary

Background -> Scripting: generateReportInContentScript(data, format)
Scripting -> Generator: generate(data, format)
Generator --> Scripting: Отчёт в выбранном формате
Scripting --> Background: report
Background -> Tabs: Закрыть вкладку проверки
Background --> Popup: { report, format }
Popup -> Popup: Показать сводку
Popup --> User: "Проверка успешно завершена!"
@enduml
```

---

## 5. Диаграмма последовательности: просмотр и сохранение отчёта

```plantuml
@startuml
actor "Пользователь" as User
participant "Popup UI" as Popup
participant "Report Preview" as Preview
participant "chrome.storage.local" as Storage
participant "ReportGenerator" as Generator
participant "Файловая система\nбраузера" as Download
participant "Буфер обмена" as Clipboard

User -> Popup: Смотрит краткую сводку

alt Скачать отчёт
  User -> Popup: Нажимает "Скачать отчёт"
  Popup -> Generator: Подготовить содержимое\nпод текущий формат
  Generator --> Popup: fileContent
  Popup -> Download: Создать Blob и ссылку download
  Download --> User: Файл accessibility-report-ГГГГ-ММ-ДД
else Скопировать отчёт
  User -> Popup: Нажимает "Скопировать"
  Popup -> Generator: Подготовить текст отчёта
  Generator --> Popup: text
  Popup -> Clipboard: writeText(text)
  Clipboard --> Popup: Текст скопирован
  Popup --> User: Показать успешный статус
else Просмотреть отчёт
  User -> Popup: Нажимает "Просмотреть отчёт"
  Popup -> Storage: Сохранить currentReport
  Popup -> Preview: chrome.windows.create(report-popup.html)
  Preview -> Storage: Получить currentReport
  Storage --> Preview: Данные отчёта
  Preview -> Preview: Построить список проблем\nи сводку
  User -> Preview: Применяет фильтры\nпо типу и категории
  Preview --> User: Обновлённый список проблем
end
@enduml
```

---

## 6. Диаграмма активности: запуск проверки

```plantuml
@startuml
start

:Открыть popup расширения;
:Подставить URL активной вкладки\nили загрузить lastUrl;
:Выбрать формат отчёта;
:Нажать "Проверить доступность";

if (URL заполнен?) then (да)
else (нет)
  :Показать ошибку\n"Введите URL-адрес";
  stop
endif

if (URL начинается с http:// или https://?) then (да)
else (нет)
  :Показать ошибку\n"Введите действительный URL";
  stop
endif

:Сохранить URL и формат\nв chrome.storage.local;
:Заблокировать кнопку\nи показать статус проверки;
:Отправить checkAccessibility\nв background.js;
:Создать скрытую вкладку\nс проверяемым сайтом;

if (Страница загрузилась\nза 30 секунд?) then (да)
else (нет)
  :Вернуть ошибку таймаута;
  :Закрыть вкладку проверки;
  stop
endif

:Внедрить утилиты и content-script.js;

if (Зависимости готовы\nза 10 секунд?) then (да)
else (нет)
  :Вернуть ошибку инициализации;
  :Закрыть вкладку проверки;
  stop
endif

:Запустить runA11yChecks();
:Собрать issues и summary;

if (Результат содержит\nissues и summary?) then (да)
else (нет)
  :Вернуть ошибку формата данных;
  :Закрыть вкладку проверки;
  stop
endif

:Сгенерировать отчёт\nв выбранном формате;
:Закрыть вкладку проверки;
:Показать сводку результатов\nв popup;
:Разблокировать действия\nскачивания, копирования и просмотра;

stop
@enduml
```

---

## 7. Диаграмма активности: анализ DOM и формирование проблем

```plantuml
@startuml
start

:Запустить content-script.js\nна проверяемой странице;
:Установить флаг\na11yInspectorReady;
:Инициализировать зависимости;

if (A11yRuleUtils доступен?) then (да)
  :Выполнить A11yRuleUtils.runAllChecks();
else (нет)
  :Выполнить резервные\nбазовые проверки;
endif

:Проверить title страницы;
:Проверить autocomplete\nи помощь в формах;
:Проверить контраст текста;
:Проверить контраст\nнетекстовых элементов;
:Проверить устойчивость\nк text-spacing;
:Проверить hover/focus content;
:Проверить порядок фокуса\nи keyboard traps;
:Проверить label-in-name\nи status messages;
:Проверить целостность ID,\nARIA и aria-current;
:Проверить клавиатурную\nнавигацию и семантику;
:Проверить язык страницы\nи язык частей контента;

if (Во время проверки\nвозникла ошибка?) then (да)
  :Добавить issue типа error\nкатегории system;
endif

:Посчитать total, errors,\nwarnings;
:Вернуть AccessibilityReport\nв background.js;

stop
@enduml
```
