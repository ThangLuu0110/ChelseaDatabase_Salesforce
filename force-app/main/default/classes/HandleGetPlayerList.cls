@RestResource(urlMapping='/player-list')
global class HandleGetPlayerList {
    public class CustomErrorResponse{
        public String message;

        public CustomErrorResponse(String message){
            this.message = message;
        }
    }

    public class PlayerInformation{
        public String playerId;
        public String playerName;
        public String playerNation;
        public String playerPosition;
        public Decimal playerShirtNumber;
        public Decimal playerAge;
        public Date playerDateOfBirth;
        public Decimal playerHeight;
        public Boolean playerLoan;
        public String playerClubPeriod;
        
        public PlayerInformation(String playerId, String playerName, String playerNation, String playerPosition, Decimal playerShirtNumber, Decimal playerAge, Date playerDateOfBirth, Decimal playerHeight, Boolean playerLoan, String playerClubPeriod){
            this.playerId = playerId;
            this.playerName = playerName;
            this.playerNation = playerNation;
            this.playerPosition = playerPosition;
            this.playerShirtNumber = playerShirtNumber;
            this.playerAge = playerAge;
            this.playerDateOfBirth = playerDateOfBirth;
            this.playerHeight = playerHeight;
            this.playerLoan = playerLoan;
            this.playerClubPeriod = playerClubPeriod;
        }
    }

    public class OutputInfo{
        public String message;
        List<PlayerInformation> data;
        
        public OutputInfo(String message, List<PlayerInformation> data){
            this.message = message;
            this.data = data;
        }
    }

    public static String getListField(){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Football_Players__c').getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        List<String> lstFieldNames = new List<String>(setFieldNames);
        return String.join(lstFieldNames, ',');
    }

    public static List<PlayerInformation> getAllPlayersList(String playerId, String playerName, String playerNationality, String playerPosition){
        List<PlayerInformation> playerInformationList = new List<PlayerInformation>();
        String databaseQuery = 'SELECT ' + getListField() + ' FROM Football_Players__c';
        List<Football_Players__c> playerList = new List<Football_Players__c>();
        if(playerId == null && playerPosition == null && playerName == null && playerNationality == null){
            playerList = Database.query(databaseQuery);
        } else {
            databaseQuery += ' WHERE';
            if(playerId != null){
                databaseQuery += ' Id =: ' + playerId;
            }

            if(playerName != null){
                System.debug(playerName);
                if(playerId != null){
                    databaseQuery += ' AND';
                }
                databaseQuery += ' Name = ' + '\'' + playerName + '\'';
            }

            if(playerNationality != null){
                if(playerId != null || playerName != null){
                    databaseQuery += ' AND';
                }
                databaseQuery += ' Nationality__c = ' + '\'' + playerNationality + '\'';
            }

            if(playerPosition != null){
                if(playerId != null || playerName != null || playerNationality != null){
                    databaseQuery += ' AND';
                }
                databaseQuery += ' Position__c = ' + '\'' + playerPosition + '\'';
            }
            playerList = Database.query(databaseQuery);
        }

        for(Football_Players__c player : playerList){
            playerInformationList.add(new PlayerInformation(player.Id, player.Name, player.Nationality__c, player.Position__c, player.Shirt_Number__c, player.Age__c, player.Date_of_Birth__c, player.Height__c, player.Loan_Transfer__c, player.Club_Period__c));
        }
        return playerInformationList;
    }



    @HttpGet
    global static void getOutputPlayerList(){
        String playerId = RestContext.request.params.get('playerId');
        String playerName = RestContext.request.params.get('name');
        String playerNationality = RestContext.request.params.get('nationality');
        String playerPosition = RestContext.request.params.get('position');
        try{
            List<PlayerInformation> playerInformationList = new List<PlayerInformation>(getAllPlayersList(playerId, playerName, playerNationality, playerPosition));
            OutputInfo success = new OutputInfo('SUCCESS_REQUEST', playerInformationList);
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(success));
        } catch(Exception e) {
            CustomErrorResponse err = new CustomErrorResponse(e.getMessage());
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(err));
            RestContext.response.statusCode = 500;
        }   
        
    }
}