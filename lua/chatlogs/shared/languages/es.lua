-- Spanish 
ChatlogLanguage["es"] = {
    DisplayName = "Spanish",
    Flag = "es",
    Time = "Tiempo",
    Player = "Jugador",
    Message = "Mensaje",
    EmptyLog = "¡Vacío!",
    Unauthorized = "¡Permisos insuficientes!",
    innocent = "INOCENTE",
    traitor = "TRAIDOR",
    detective = "DETECTIVE",
    spectator = "ESPECTADOR",
    ClipboardCopy = "Copiar al portapapeles",
    ClipboardCopied = "¡Mensaje copiado al portapapeles!",
    Round = "Ronda ",
    RoundFilter = "Filtrar por ronda:",
    RoundSelect = "Elegir ronda",
    RoundSelectCurrent = "Ronda actual",
    CantReadPresent = "No tienes permiso a leer los registros de la ronda actual.",
    NoFilterChosen = "Por favor selecciona una ronda/filtro antes de refrescar.",
    Refresh = "Actualizar",
    ChatTab = "Chatlog",
    SettingsTab = "Opciones",
    SelectedMessage = "Mensaje seleccionado:",
    SelectedMessageNone = "¡Ningún mensaje seleccionado!",
    LanguageTab = "Idioma",
    Licensing = "Chatlogs v" .. Chatlog.Version .. " por actuallyNothing, licenciado bajo GPL-3.0.",
    SwitchedLanguage = "¡Idioma de Chatlog cambiado!",
    LastRoundMap = "Última ronda del mapa anterior",
    CopiedSteamID = "SteamID de %s copiada (%s)",
    GetSteamID = "Copiar SteamID de %s",

    SelectARound = "Seleccione una ronda",
    NoRoundSelected = "Ninguna ronda seleccionada",
    -- https://wiki.facepunch.com/gmod/os.date
    RoundInfoTime = "%A | %d de %B, %Y | %X",
    RoundInfoError = "Error encontrado",

    FiltersButtonShow = "  Más filtros",
    FiltersButtonHide = "  Menos filtros",
    FiltersTitle = "Filtros",
    FiltersOnlyTeam = "Ver solo mensajes de equipo",

    FiltersRoles = "Ver solo mensajes de:",
    FiltersRolesInnocent = "Inocentes",
    FiltersRolesTraitor = "Traidores",
    FiltersRolesDetective = "Detectives",

    FiltersHideRadio = "Ocultar mensajes de radio",
    FiltersOnlySubstringsTitle = "Ver solo mensajes que contengan:",
    FiltersOnlySubstringsPlaceholder = "c4, traidor, detective",
    FiltersOnlySubstringsTip = "Separa con comas para filtrar varias palabras distintas. Ejemplo: 'hola, mundo'",

    FiltersPlayers = "Ver solo mensajes de:",
    FiltersPlayersNoPlayersFound = "No se encontraron jugadores",

    EmptyLogFilters = "No hay mensajes que coincidan con los filtros seleccionados.",

    TextPanelMessageInfo = "Información del Mensaje",
    TextPanelTip = "¡Seleciona un mensaje para verlo aquí!",

    TextPanelTo = " para ",
    TextPanelTeam = "EQUIPO",
    TextPanelAll = "TODOS",
    TextPanelOnRadio = " POR RADIO",
    TextPanelDeadPrefix = "*MUERTO* ",

    PlayerListButtonShow = "  Mostrar jugadores",
    PlayerListButtonHide = "  Esconder jugadores",
    PlayerList = "Jugadores",
    PlayerListName = "Nombre",
    PlayerListNoPlayers = "No se encontraron jugadores",

    Cancel = "Cancelar",
    SaveChanges = "Guardar cambios",
    Confirm = "Confirmar",

    AdminTab = "Administrar",
    AdminUsergroups = "Grupos",

    AdminNewGroup = "Nuevo grupo",
    AdminNewGroupTitle = "Añadiendo un grupo",
    AdminNewGroupTip = "Ingrese el nombre del nuevo grupo:",
    AdminNewGroupAdd = "Añadir grupo",
    AdminNewGroupError = "Error añadiendo grupo: ",
    AdminGroupExists = "¡Ese grupo ya existe!",
    AdminCopyGroup = "Copiar el nombre de este grupo al portapapeles",
    AdminCopiedGroup = "¡Nombre del grupo copiado al portapapeles!",
    AdminDeleteGroup = "Eliminar este grupo",

    AdminMySQLSettings = "Opciones de MySQL",
    AdminHoverToShow = "Pase el ratón para ver",
    AdminMySQLReview = "Antes de establecer MySQL como su base de datos, revise la siguiente información:",

    MySQLHost = "IP / Host:",
    MySQLPort = "Puerto:",
    MySQLUsername = "Nombre de usuario:",
    MySQLPassword = "Contraseña:",
    MySQLDatabase = "Base de datos:",

    AdminCommitTitle = "Confirmar cambios a la configuración",
    AdminCommitWarning = "Confirmar los cambios re-enviará el archivo de configuración a todos los jugadores. Confirmar?",
    AdminCommiting = "Confirmando cambios...",

    AdminPrivilegeTitle = "Configuración de privilegios",
    AdminPrivilegeSelectGroup = "Seleccione un grupo para editar",
    AdminPrivilegeEditing = "Editando: (%s)",

    AdminPrivilegeReadPresent = "Puede leer mensajes de la ronda actual:",
    AdminPrivilegeReadPresentAlways = "Siempre",
    AdminPrivilegeReadPresentNever = "Nunca",
    AdminPrivilegeReadPresentSpecOnly = "Solo estando muerto o de espectador",

    AdminPrivilegeReadTeam = "Puede leer mensajes de equipo (traidores y detectives)",
    AdminPrivilegeReadDead = "Puede leer a jugadores muertos o espectadores",
    AdminPrivilegeSearchByDate = "Puede buscar registros por fecha",

    AdminServerTitle = "Configuración del servidor",

    AdminServerKeybind = "Activar F7 como tecla rápida de Chatlog",
    AdminServerKeybindTooltip = "Al desactivarse, los jugadores deben escribir el comando 'chatlog' para abrir la ventana de Chatlog",

    AdminServerUseMySQL = "Usar MySQL para guardar registros",
    AdminServerUseMySQLTooltip = "Al desactivarse, el servidor usará la base de datos SQLite incluida",

    AdminServerDayLimit = "Límite de entradas en la base de datos",

    Month1 = "Enero",
    Month2 = "Febrero",
    Month3 = "Marzo",
    Month4 = "Abril",
    Month5 = "Mayo",
    Month6 = "Junio",
    Month7 = "Julio",
    Month8 = "Agosto",
    Month9 = "Septiembre",
    Month10 = "Octubre",
    Month11 = "Noviembre",
    Month12 = "Diciembre",

    OldLogsTab = "Logs antiguos",

    OldLogsCodeTitle = "Buscar por código",
    OldLogsCodeTip = "Cada ronda tiene un código único de 6 carácteres que puede usarse para buscarla en los logs antiguos.",
    OldLogsCodeLabel = "Código:",
    OldLogsCodeButton = "Buscar",

    OldLogsDateTitle = "Buscar por fecha",
    OldLogsDateTip = "Cada ronda puede buscarse por la fecha y hora en que se jugó.",
    OldLogsDateBetween = "Rondas entre %s y %s",
    OldLogsDateLoad = "Cargar ronda",

    CopyRoundCode = "Copiar el código de esta ronda",
    CopiedRoundCode = "¡Código copiado al portapapeles! (%s)",

    ServerResponseNoRoundFound = "No se encontró ninguna ronda con ese código.",
    ServerResponseInvalidCode = "Código inválido.",
    ServerResponseOK = "Cargando ronda...",

    Role = "Rol",

}
