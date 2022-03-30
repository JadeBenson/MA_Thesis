# The objective of this script is to retrieve data from the 2010 - 2014 5 year American Census Survey (ACS) at the county level
# This dataset will be merged with the others in Python 

library(tidycensus)
library(data.table)
library(magrittr)
library(tidyr)
library(acs)
library(dplyr)

# assemble list of variables (so can grab their definitions)
variable_list <-load_variables(2015, "acs5", cache = TRUE)

View(variable_list)

##county statistics 

#total population: B00001_001
#total housing: B00001_002
total_pop <-  c('B00001_001')                     
total_houses <- c('B00001_002')

#median income in the county: B06011_001 
median_income <- c('B06011_001')

#B17020_002 total below poverty, (total people = B17020_001)
total_poor <- c('B17020_001', 'B17020_002')

#Gini index of income inequality 
#B19083_001
gini <- c('B19083_001')

##Age Specific 

#total population over 65 
#Male sex by age: B01001_020 - B01001_025
#Female sex by age: B01001_044 - B01001_049
#older sex by age by race: B01001(A/B/C/D/E/F/G/H/I)_014 - 16, B01001(A/B/C/D/E/F/G/H/I)29 - 31, 
#likely will do H - White not Hispanic, I - Hispanic, B - African American, sum the rest "other"


sex_by_age <- c('B01001_020', 'B01001_021', 'B01001_022','B01001_023', 'B01001_024','B01001_025',
               'B01001_044','B01001_045', 'B01001_046', 'B01001_047', 'B01001_048', 'B01001_049')


sex_by_age_race <- c('B01001A_014','B01001A_015', 'B01001A_016', 'B01001A_029', 'B01001A_030', 'B01001A_031',
                      'B01001B_014','B01001B_015', 'B01001B_016', 'B01001B_029', 'B01001B_030', 'B01001B_031',
                      'B01001C_014','B01001C_015', 'B01001C_016', 'B01001C_029', 'B01001C_030', 'B01001C_031', 
                      'B01001D_014','B01001D_015', 'B01001D_016', 'B01001D_029', 'B01001D_030', 'B01001D_031', 
                      'B01001E_014','B01001E_015', 'B01001E_016', 'B01001E_029', 'B01001E_030', 'B01001E_031', 
                      'B01001F_014','B01001F_015', 'B01001F_016', 'B01001F_029', 'B01001F_030', 'B01001F_031', 
                      'B01001G_014','B01001G_015', 'B01001G_016', 'B01001G_029', 'B01001G_030', 'B01001G_031', 
                      'B01001H_014','B01001H_015', 'B01001H_016', 'B01001H_029', 'B01001H_030', 'B01001H_031', 
                      'B01001I_014','B01001I_015', 'B01001I_016', 'B01001I_029', 'B01001I_030', 'B01001I_031') 


#could pull all demographic variables - COMEBACK TO THIS, just 65 for now 
#B00001_001 - B01001I_031
  

#poverty status by age (those 60 and older)
#then could do this by race too (A-I subcodes again)

poverty_status <- c('B17020_002', 'B17020_007', 'B17020_008', 'B17020_009') 

#age by ratio to poverty line

create_codes <- function(base_code, start, end) {
  difference <- end-start
  code_vars <- vector("character", difference)
  
  for (i in seq.int(start, end)){
    
    if(start == 1){
      index = i
    } else {
      index = i - start

    }
    
    if(i < 10){
      
      code_vars[index] <- paste(base_code, i, sep = "0")
      
    } else{
      code_vars[index] <- paste(base_code, i, sep = "")
      
    }
    
  }
  return(code_vars)
}


#age by ratio to poverty line 
#B17024_106

age_ratio_poverty <- create_codes('B17024_1', 6, 31)

#total men over 65 for education: B15001_035, total women for education: B15001_076 
#men over 65 by educational attainment: B15001_036 - 42
#women over 65 by educational attainment: B15001_077 - 83
men_education <- create_codes('B15001_0', 35, 42)
women_education <- create_codes('B15001_0', 76, 83)
education <- c(men_education, women_education)

#living arrangements by age (who they live with)
#B09021_022 - 28
living_arrangement <- create_codes('B09021_0', 22, 28)

#sex by working status (over 65)
#B23026_001
#male worked in past 6 months: B23026_003, male did not work in past year B23026_025
#female worked in past 6 months: B23026_027, female didn't work: B23026_049
working_status <- create_codes('B23026_0', 1, 49)

#I don't have these yet - idk if important 
#transportation to work by age? B08101_001

#insurance type by age and sex? 

# assemble list of variables to retrieve
metrics <- c(total_pop, total_houses, median_income, total_poor, gini, 
             sex_by_age, sex_by_age_race, poverty_status, age_ratio_poverty, 
             education, living_arrangement, working_status) 
             

length(metrics)
#170 variables

metrics<-as.data.table(metrics)
colnames(metrics)<-'name'

# develop label list
label_list<-subset(variable_list, variable_list$name %in% metrics$name)
label_table <- merge(metrics, label_list, by="name")

#rm(variable_list, metrics)


api_key <- "9ac54239b8aafd59634427adaea600eccd5a42cb"

# loop through
b<-list()

for(j in 1:nrow(label_table)){
    
    out <- tryCatch({
    variable = label_table$name[j]
    
    a<-get_acs(
    geography = "county", 
    survey = "acs5",
    variables = variable, 
    year = 2014, 
    geometry = FALSE, 
    key = api_key
    )
    
    b[[j]]<-a}, 
    error=function(cond){
      message("API fail:")
      message(cond)
    }
    
    )
    

}
return(out)
#failed only 2 - that's great! 

full_df <- dplyr::bind_rows(b)

#save this as csv and can mess around with converting this to a wide format there 

write.csv(full_df, "/Users/jadebenson/Documents/Thesis/ACS_variables_long.csv")


##Now want to make this into a more interpretable format where it's proportions for every variable

full_df <- read.csv("/Users/jadebenson/Documents/Thesis/ACS_variables_long.csv")

View(full_df)

#want to drop index, county name and moe 
full_df <- full_df[, c(-1,-3,-6)]

#pivot to wide format 
acs_df <- full_df %>%
  pivot_wider(names_from = variable, values_from = estimate)

#Variables we want:

#population density, - NEED COUNTY AREA 

acs_df <- acs_df %>%
  rename(total_pop = B00001_001)

#total population over 65 
#Male sex by age: B01001_020 - B01001_025
#Female sex by age: B01001_044 - B01001_049
#male_age_vars <- c('B01001_020', 'B01001_021', 'B01001_022', 'B01001_023', 'B01001_024', 'B01001_025')
#female_age_vars <-  c('B01001_044', 'B01001_045', 'B01001_046', 'B01001_047', 'B01001_048', 'B01001_049')
acs_df <- acs_df %>%
  rename(male_65_66 = B01001_020,
         male_67_69 = B01001_021, 
         male_70_74 = B01001_022, 
         male_75_79 = B01001_023, 
         male_80_84 = B01001_024,
         male_85andup = B01001_025,
         female_65_66 = B01001_044,
         female_67_69 = B01001_045, 
         female_70_74 = B01001_046, 
         female_75_79 = B01001_047, 
         female_80_84 = B01001_048,
         female_85andup = B01001_049
         )

#create total 65+ population 
age_vars <- c('male_65_66', 
              'male_67_69', 
              'male_70_74',
              'male_75_79', 
              'male_80_84', 
              'male_85andup', 
              'female_65_66', 
              'female_67_69', 
              'female_70_74', 
              'female_75_79',
              'female_80_84',
              'female_85andup')

acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(pop_65_up = sum(c_across(age_vars), na.rm = T)) %>% 
  ungroup() 

summary(acs_df$pop_65_up)

#proportion of 65+ that are 85+ 
acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(pop_85_up = sum(c_across(c('male_85andup', 'female_85andup')), na.rm = T)) %>% 
  ungroup() 

acs_df <- transform(acs_df, prop_65_85_up = pop_85_up / pop_65_up)

summary(acs_df$prop_65_85_up)

#proportion of 65+ that's female
acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(pop_female = sum(c_across(c('female_65_66', 
                                     'female_67_69', 
                                     'female_70_74', 
                                     'female_75_79',
                                     'female_80_84',
                                     'female_85andup')), na.rm = T)) %>% 
  ungroup() 

acs_df <- transform(acs_df, prop_female = pop_female / pop_65_up)
summary(acs_df$prop_female)
acs_df[acs_df$prop_female == 1.0,]

#Gini index and the median income
  #Gini index of income inequality B19083_001
  #median income in the county: B06011_001 
acs_df <- acs_df %>%
  rename(gini_index = B19083_001,
         median_income = B06011_001)

#proportion non-Hispanic white
#older sex by age by race: B01001(A/B/C/D/E/F/G/H/I)_014 - 16, B01001(A/B/C/D/E/F/G/H/I)29 - 31, 
#A is "White Alone" but H is "Non-Hispanic White" - I'll sum all the Non-hispanic white and divide by B, C, D, E, F, G, I

#white, non-Hispanic population over 65
acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(white_nonhispanic = sum(c_across(c('B01001H_014', 
                                     'B01001H_015', 
                                     'B01001H_016', 
                                     'B01001H_029',
                                     'B01001H_030',
                                     'B01001H_031')), na.rm = T)) %>% 
  ungroup() 

#all other races population over 65 
all_other_races <- c('B01001B_014','B01001B_015', 'B01001B_016', 'B01001B_029', 'B01001B_030', 'B01001B_031',
                     'B01001C_014','B01001C_015', 'B01001C_016', 'B01001C_029', 'B01001C_030', 'B01001C_031', 
                     'B01001D_014','B01001D_015', 'B01001D_016', 'B01001D_029', 'B01001D_030', 'B01001D_031', 
                     'B01001E_014','B01001E_015', 'B01001E_016', 'B01001E_029', 'B01001E_030', 'B01001E_031', 
                     'B01001F_014','B01001F_015', 'B01001F_016', 'B01001F_029', 'B01001F_030', 'B01001F_031', 
                     'B01001G_014','B01001G_015', 'B01001G_016', 'B01001G_029', 'B01001G_030', 'B01001G_031', 
                     'B01001I_014','B01001I_015', 'B01001I_016', 'B01001I_029', 'B01001I_030', 'B01001I_031') 


acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(other_races_pop = sum(c_across(all_other_races), na.rm = T)) %>% 
  ungroup() 

#this population might be slightly different that responds to race 
#sum these two categories for new race-answering population 
acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(race_pop = sum(c_across(c('white_nonhispanic', 'other_races_pop')), na.rm = T)) %>% 
  ungroup() 

#only about a third of the race populations are equal to total population 65+ 
sum(acs_df$race_pop == acs_df$pop_65_up) / length(acs_df$GEOID)
#it looks like the race population is larger than total population... 
#I think this is because people can check many race categories 
#I'll just use white only, not hispanic divided by total population 

acs_df <- transform(acs_df, prop_white_nh = white_nonhispanic / pop_65_up)


#proportion institutionalized - this isn't quite it
#living arrangements by age (who they live with)
#B09021_022 - 28
#total living arrangements of those over 65 B09021_022 
#those that live alone (B09021_023) and other nonrelatives B09021_028
#I'll come back to this if needed - should look more into if institutionalized adults included in census 


#proportion under the poverty line

#age by ratio to poverty line 
#B17024_106 - 31

#sum those who are 65+ who are below the poverty line
poverty_line_below <- c('B17024_107', 'B17024_108', 'B17024_109', 
                        'B17024_120', 'B17024_121', 'B17024_122')

acs_df <- acs_df %>%
  rowwise() %>% 
  mutate(below_poverty_line = sum(c_across(poverty_line_below), na.rm = T)) %>% 
  ungroup()

acs_df <- transform(acs_df, prop_poor = below_poverty_line / pop_65_up)
summary(acs_df$prop_poor)

#additional collected variables

#I think this is actually income of those below poverty line - values don't make sense
#B17020_002 total below poverty, (total people = B17020_001)
#poverty status by age (those 60 and older)
#then could do this by race too (A-I subcodes again) c('B17020_002', 'B17020_007', 'B17020_008', 'B17020_009') 


#total men over 65 for education: B15001_035, total women for education: B15001_076 
#men over 65 by educational attainment: B15001_036 - 42
#women over 65 by educational attainment: B15001_077 - 83


#total housing: B00001_002

#sex by working status (over 65)
#B23026_001
#male worked in past 6 months: B23026_003, male did not work in past year B23026_025
#female worked in past 6 months: B23026_027, female didn't work: B23026_049


####
#now remove all variables starting with 'B' and save 
columns_to_remove <- grep("B", names(acs_df))
#columns_to_remove

acs_df <- acs_df %>% 
  select(-columns_to_remove)

#make this even smaller 
names(acs_df)
columns_to_keep <- c("GEOID", "total_pop", "median_income", "gini_index", "pop_65_up", "prop_65_85_up", "prop_female", "prop_white_nh", "prop_poor") 

final_acs_df <- acs_df[columns_to_keep]
View(final_acs_df)
summary(final_acs_df)

#save this 
final_acs_df$total_pop = as.double(final_acs_df$total_pop)
final_acs_df$median_income = as.double(final_acs_df$median_income)
final_acs_df$gini_index = as.double(final_acs_df$gini_index)

write.csv(final_acs_df, "/Users/jadebenson/Documents/Thesis/final_ACS_vars.csv")

