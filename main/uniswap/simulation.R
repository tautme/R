library(tidyverse)
library(latex2exp)

setwd("C:/Users/Wenyao/Desktop/R/R/")
source("./functions/functions_save_png.R")
source("./functions/functions_uniswap.R")


#==== general setup ====
set.seed(1)

# number of paths
N <- 1e5


#==== simulation ====
v <- simulate_uniswap_returns(
  mu_A = 0.001, mu_B = 0.002,
  sigma_A = 0.02, sigma_B = 0.05,
  rho = 0.8,
  fee = 0.3 / 100,
  N = N, t = 1000, dt = 1,
  A0 = 100, B0 = 200,
  a0 = 20000
)

v_fee <- map(
  c(0, 0.15, 0.3, 1, 5, 20) / 100,
  function(fee){
    print(fee)
    simulate_uniswap_returns(
      mu_A = 0.001, mu_B = 0.002,
      sigma_A = 0.02, sigma_B = 0.05,
      rho = 0.8,
      fee = fee,
      N = N, t = 1000, dt = 1,
      A0 = 100, B0 = 200,
      a0 = 20000
    ) %>% 
      mutate(
        fee = paste0(fee * 100, "%") %>% 
          factor(levels = paste0(c(0, 0.15, 0.3, 1, 5, 20), "%"))
      )
  }
) %>% 
  bind_rows() %>% 
  gather(
    type, value, -fee, -`Total Fees`
  )

v_rho <- map(
  c(-0.5, 0, 0.5, 0.8, 0.9, 1),
  function(rho){
    print(rho)
    simulate_uniswap_returns(
      mu_A = 0.001, mu_B = 0.002,
      sigma_A = 0.02, sigma_B = 0.05,
      rho = rho,
      fee = 0.3 / 100,
      N = N, t = 1000, dt = 1,
      A0 = 100, B0 = 200,
      a0 = 20000
    ) %>% 
      mutate(
        rho = rho
      )
  }
) %>% 
  bind_rows() %>% 
  gather(
    type, value, -rho, -`Total Fees`
  )


#==== plot =====
plot1 <- v %>% 
  gather(
    type, value, -`Total Fees`
  ) %>%
  ggplot(aes(x = value)) +
  geom_density(aes(fill = type), alpha = 0.5, color = NA) +
  geom_vline(xintercept = 0, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("Liquidity Provider" = "tomato", "Buy and Hold" = "dodgerblue")) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    text = element_text(size = 20),
    axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    plot.subtitle = element_text(size = 15),
    legend.spacing.x = unit(0.5, 'cm')
  ) +
  labs(
    title = "Return Distributions of Buy and Hold vs Liquidity Provider", 
    subtitle = TeX('$\\mu^A = 0.1%,\\; \\mu^B = 0.2%,\\; \\sigma^A = 2%,\\; \\sigma^B = 5%,\\; \\rho = 0.8,\\; A_0 = 100,\\; B_0 = 200,\\; c = 0.3%,\\; t = 1000 $'),
    x = "Return"
  ) +
  xlim(c(-1, 10))

plot1.1 <- v %>% 
  transmute(
    `Fee Return` = `Total Fees`,
    `Price Slippage Return` = `Liquidity Provider` - `Fee Return`
  ) %>% 
  summarise(
    `Fee Return` = mean(`Fee Return`),
    `Price Slippage Return` = mean(`Price Slippage Return`)
  ) %>% 
  gather(
    type, value
  ) %>%
  ggplot(aes(x = type)) +
  geom_bar(aes(weight = value, fill = type)) +
  scale_fill_manual(values = c("Price Slippage Return" = "tomato", "Fee Return" = "dodgerblue")) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    text = element_text(size = 20),
    axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    plot.subtitle = element_text(size = 15),
    legend.spacing.x = unit(0.5, 'cm')
  ) +
  labs(
    title = "Return Distributions of Buy and Hold vs Liquidity Provider", 
    subtitle = TeX('$\\mu^A = 0.1%,\\; \\mu^B = 0.2%,\\; \\sigma^A = 2%,\\; \\sigma^B = 5%,\\; \\rho = 0.8,\\; A_0 = 100,\\; B_0 = 200,\\; c = 0.3%,\\; t = 1000 $'),
    x = "Return"
  ) +
  xlim(c(-1, 10))

plot2 <- v_fee %>% 
  ggplot(aes(x = value)) +
  geom_density(aes(fill = type), alpha = 0.5, color = NA) +
  geom_vline(xintercept = 0, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("Liquidity Provider" = "tomato", "Buy and Hold" = "dodgerblue")) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    text = element_text(size = 20),
    axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    plot.subtitle = element_text(size = 18),
    legend.spacing.x = unit(0.5, 'cm')
  ) +
  facet_grid(fee~., switch = "y") +
  labs(
    title = "Return Distributions under Various Fee Schedules", 
    subtitle = TeX('$ c = 0%,\\; 0.15%,\\; 0.3%,\\; 1%,\\; 5%,\\; 20% $'),
    x = "Return"
  ) +
  xlim(c(-1, 10))

plot3 <- v_rho %>%
  ggplot(aes(x = value)) +
  geom_density(aes(fill = type), alpha = 0.5, color = NA) +
  geom_vline(xintercept = 0, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("Liquidity Provider" = "tomato", "Buy and Hold" = "dodgerblue")) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    text = element_text(size = 20),
    axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    plot.subtitle = element_text(size = 18),
    legend.spacing.x = unit(0.5, 'cm')
  ) +
  facet_grid(rho~., switch = "y") +
  labs(
    title = "Return Distributions under Various Correlation Assumptions",
    subtitle = TeX('$ \\rho = -0.5,\\; 0,\\; 0.5,\\; 0.8,\\; 0.9,\\; 1 $'),
    x = "Return"
  ) +
  xlim(c(-1, 10))


#===== output =====
save_png(
  plot1,
  file_name = "output/uniswap/return.png",
  width = 800,
  height = 300
)

save_png(
  plot2,
  file_name = "output/uniswap/return_vs_fees.png",
  width = 800,
  height = 800
)

save_png(
  plot3,
  file_name = "output/uniswap/return_vs_rhos.png",
  width = 800,
  height = 800
)

baseline <- v %>% 
  gather(
    type, value, -`Total Fees`
  ) %>%
  group_by(type) %>% 
  summarise(
    expected_return = mean(value),
    volatility = sd(value),
    sharpe_ratio = expected_return / volatility
  )

sensitivity_fee <- v_fee %>% 
  group_by(fee, type) %>% 
  summarise(
    expected_return = mean(value),
    volatility = sd(value),
    sharpe_ratio = expected_return / volatility
  )

sensitivity_rho <- v_rho %>% 
  group_by(rho, type) %>% 
  summarise(
    expected_return = mean(value),
    volatility = sd(value),
    sharpe_ratio = expected_return / volatility
  ) %>% 
  mutate_if(is.numeric, round, 2)

baseline %>% 
  mutate_if(is.numeric, round, 2) %>%
  write.table("clipboard-128", row.names = FALSE, sep = " | ")

sensitivity_fee %>% 
  mutate_if(is.numeric, round, 2) %>%
  write.table("clipboard-128", row.names = FALSE, sep = " | ")

sensitivity_rho %>%
  write.table("clipboard-128", row.names = FALSE, sep = " | ")

sensitivity_fee %>% 
  ggplot(aes(x = volatility, y = expected_return)) +
  geom_point(aes(color = type), size = 2) +
  geom_text(aes(label = fee), size = 5, position = position_jitter(width = 0, height = 1)) +
  scale_color_manual(values = c("Liquidity Provider" = "tomato", "Buy and Hold" = "dodgerblue")) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    text = element_text(size = 20),
    axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
    axis.title.y = element_blank(),
    plot.subtitle = element_text(size = 18)
  ) 



sensitivity_rho %>% 
  rename(comment = rho) %>% 
  mutate(comment = paste0("ρ = ", comment), comment2 = "rho") %>% 
  ggplot(aes(x = volatility, y = expected_return)) +
  geom_point(aes(color = type, shape = comment2), size = 2) +
  scale_color_manual(values = c("Liquidity Provider" = "tomato", "Buy and Hold" = "dodgerblue")) +
  theme_minimal() +
  theme(
    legend.position = "top",
    legend.title = element_blank(),
    text = element_text(size = 20),
    axis.title.x = element_text(margin = margin(t = 15, r = 0, b = 0, l = 0)),
    axis.title.y = element_blank(),
    plot.subtitle = element_text(size = 18)
  ) +
  xlim(c(0, NA)) +
  ylim(c(0, NA))
