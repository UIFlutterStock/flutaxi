

enum LocalLocation{
  Source,
  Destiny
}


enum TravelStatus{
  Open,
  AguardadandoMotorista,
  AwaitingDriver,
  DriverPath,
  Started,
  Finished,
  Canceled
}

enum ActionReport {
  Edit,
  Delete
}


enum StepDriverHome {
  Start, /*primeira etapa do processo*/
  LookingTravel, /*procurando motorista*/
  TripFound, /*notifica ao motorista com pergunta se ele quer aceitar*/
  TravelAccept, /*motorista aceitou viagem, motorista vai até o passageiro*/
  StartTrip, /*motorista aceitou viagem, motorista vai até o passageiro*/
  EndRace /*fim corrida*/
}

enum StepPassengerHome {
  Start, /*primeira etapa do processo*/
  SelectSourceDestination, /*menu com busca de itens*/
  ConfirmPrice, /*menu confirmacao de corrida*/
  SearchDriver, /*procurando motorista*/
  LookingTravel, /*procurando motorista*/
  TravelFound, /*notifica ao motorista com pergunta se ele quer aceitar*/
  DriverAccepted, /*motorista aceitou viagem, motorista vai até o passageiro*/
  RaceProgress, /*fim corrida*/
  EndRace /*fim corrida*/
}

enum TipoCarro{
  Pop,
  Top
}

enum TipoLocal{
  House,
  Job
}

enum Ambiente {
  Passenger,
  Driver
}