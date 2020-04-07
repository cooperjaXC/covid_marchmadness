filpth="C:/Users/acc-s/Documents/Publications/4_Covid19_MarchMadness/data_nonspatial/marchmadghgs_byteampertrip.csv"

ghgcsv = read.csv(filpth)

colnames(ghgcsv)

linearghgmodel = (lm(data = ghgcsv, formula = totghg ~ km + hotelghgpp + gamesplayed + attnincluptpg)) # log(km)
summary(linearghgmodel)

ppghglm = lm(data = ghgcsv, formula = ghgppptptrip ~ km + hotelghgpp + gamesplayed)
summary(ppghglm)
