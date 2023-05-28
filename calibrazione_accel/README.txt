prova_calibrazione.m contiene il codice per calcolare FATTORI DI SCALA e OFFSET da applicare ai dati reali per pulirli dall'errore
dell'accelerometro lungo le 3 dimensioni

i file calibr_x,y, e z .txt sono catture fatte ad hoc per la calibrazione della IMU e vanno usati nel file prova_calibrazione.m

ATTENZIONE:
 1) Nel file matlab prova_calibrazione sostituire i path dei file per ottenere accel_x, y e z -> al momento sono scritti i path locali al PC di Marco
 
 2)calibr_x è leggermente diverso dagli altri due : per un errore contiene prima tutti i valori negativi e poi quelli positivi. Il caso viene tuttavia correttamente gestito dall'algoritmo in prova_calibrazione