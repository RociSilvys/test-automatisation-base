@REQ_TEST-001
Feature: TEST-001 Gestión de personajes de superhéroes (microservicio para manejo de personajes)
  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    * def generarHeaders = function() { return { 'Content-Type': 'application/json' } }
    * def headers = generarHeaders()
    * configure headers = headers
    
  @id:1 @obtenerPersonajes @solicitudExitosa200
  Scenario: T-API-TEST-001-CA01-Obtener todos los personajes exitosamente 200 - karate
    * path '/characters'
    When method GET
    Then status 200
    And match response != null
    And match response[0].id != null
    And match each response contains { id: '#number', name: '#string', alterego: '#string', description: '#string', powers: '#array' }
    * def firstCharacterId = response[0].id

  @id:2 @obtenerPersonajePorId @solicitudExitosa200
  Scenario: T-API-TEST-001-CA02-Obtener personaje por ID exitosamente 200 - karate
    Given def result = callonce read('karate-test.feature@obtenerPersonajes')
    * def characterId = result.firstCharacterId
    * path '/characters/', characterId
    When method GET
    Then status 200
    And match response != null
    And match response.id == characterId
    And match response.name != null
    And match response.alterego != null
    And match response.description != null
    And match response.powers != null

  @id:3 @obtenerPersonajePorId @personajeNoExiste404
  Scenario: T-API-TEST-001-CA03-Obtener personaje por ID inexistente 404 - karate
    * path '/characters/999'
    When method GET
    Then status 404
    And match response != null
    And match response.error == 'Character not found'
    
  @id:4 @crearPersonaje @solicitudExitosa201
  Scenario: T-API-TEST-001-CA04-Crear personaje exitosamente 201 - karate
    * path '/characters'
    * def timestamp = '' + java.lang.System.currentTimeMillis()
    * def requestData = read('classpath:data/bp_se_test_api/create_character_request.json')
    * set requestData.name = 'Silvana Bentacourt v1-' + timestamp
    * request requestData
    When method POST
    Then status 201
    And match response != null
    And match response.id == '#number'
    And match response.name == 'Silvana Bentacourt v1-' + timestamp
    And match response.alterego == 'Tony Stark'
    And match response.description == 'Genius billionaire'
    And match response.powers == ['Armor', 'Flight']
    * def characterId = response.id

  @id:5 @crearPersonaje @nombreDuplicado409
  Scenario: T-API-TEST-001-CA05-Crear personaje con nombre duplicado 400 - karate
    * path '/characters'
    * def requestData = read('classpath:data/bp_se_test_api/duplicate_character_request.json')
    * request requestData
    When method POST
    Then status 400
    And match response != null
    
  @id:6 @crearPersonaje @camposRequeridosFaltantes400
  Scenario: T-API-TEST-001-CA06-Crear personaje con campos requeridos faltantes 400 - karate
    * path '/characters'
    * def requestData = read('classpath:data/bp_se_test_api/missing_fields_character_request.json')
    * request requestData
    When method POST
    Then status 400
    And match response != null

  @id:7 @actualizarPersonaje @solicitudExitosa200
  Scenario: T-API-TEST-001-CA07-Actualizar personaje exitosamente 200 - karate
    # Primero crear un personaje para luego actualizarlo
    * path '/characters'
    * def timestamp = '' + java.lang.System.currentTimeMillis()
    * def createRequestData = read('classpath:data/bp_se_test_api/create_character_request.json')
    * set createRequestData.name = 'Personaje a actualizar-' + timestamp
    * request createRequestData
    When method POST
    Then status 201
    And match response != null
    * def characterId = response.id
    
    # Actualizar el personaje creado
    * path '/characters/' + characterId
    * def updateRequestData = read('classpath:data/bp_se_test_api/update_character_request.json')
    * set updateRequestData.name = 'Personaje actualizado-' + timestamp
    * request updateRequestData
    When method PUT
    Then status 200
    And match response != null
    And match response.id == characterId
    And match response.name == 'Personaje actualizado-' + timestamp
    And match response.alterego == 'Tony Stark'
    And match response.description == 'Genius billionaire test'
    And match response.powers == ['Armor', 'Flight']

  @id:8 @actualizarPersonaje @personajeNoExiste404
  Scenario: T-API-TEST-001-CA08-Actualizar personaje inexistente 404 - karate
    * path '/characters/999'
    * def updateRequestData = read('classpath:data/bp_se_test_api/update_nonexistent_character_request.json')
    * request updateRequestData
    When method PUT
    Then status 404
    And match response != null
    And match response.error == 'Character not found'
    
  @id:9 @eliminarPersonaje @personajeNoExiste404
  Scenario: T-API-TEST-001-CA09-Eliminar personaje inexistente 404 - karate
    * path '/characters/999'
    When method DELETE
    Then status 404
    And match response != null
    And match response.error == 'Character not found'

  @id:10 @eliminarPersonaje @solicitudExitosa204
  Scenario: T-API-TEST-001-CA10-Eliminar personaje exitosamente 204 - karate
    # Primero crear un personaje para luego eliminarlo
    * path '/characters'
    * def timestamp = '' + java.lang.System.currentTimeMillis()
    * def createRequestData = read('classpath:data/bp_se_test_api/create_character_request.json')
    * set createRequestData.name = 'Personaje a eliminar-' + timestamp
    * request createRequestData
    When method POST
    Then status 201
    And match response != null
    * def characterToDelete = response.id

    # Eliminar el personaje creado
    * path '/characters/' + characterToDelete
    When method DELETE
    Then status 204
    And print response
    # Status 204 indica éxito sin contenido, por lo que no hay respuesta para validar
