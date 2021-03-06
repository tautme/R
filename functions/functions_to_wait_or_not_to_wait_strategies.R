#' stategy: "let the light guide your way"
#' 
#' @param wait_time_x a matrix of the wait time to go right at each intersection
#' @param wait_time_y a matrix of the wait time to go down at each intersection
#' @param crossroad_standard_x the maximum wait time (for red light) to go right at each intersection
#' @param crossroad_standard_y the maximum wait time (for red light) to go down at each intersection
#' @arg1 additional argument placeholder 1
#' @arg2 additional argument placeholder 2
#' 
strategy_let_the_light_guide_your_way <- function(
  wait_time_x, 
  wait_time_y,
  crossroad_standard_x,
  crossroad_standard_y,
  arg1 = NULL,
  arg2 = NULL
){
  
  # whether one goes right at crossroad
  route_x <- matrix(0, ncol = road_dim, nrow = road_dim)
  # whether one goes down at crossroad
  route_y <- matrix(0, ncol = road_dim, nrow = road_dim)
  
  position_x <- 1
  position_y <- 1
  
  while(TRUE){
    
    if(position_x == road_dim + 1 & position_y == road_dim + 1){
      
      # the ending status
      break
      
    }else if(position_x == road_dim + 1){
      
      # reachcing the boundary at the bottom
      route_x[position_x - 1, position_y] <- 1
      position_y <- position_y + 1
      
    }else if(position_y == road_dim + 1){
      
      # reachcing the boundary on the right
      route_y[position_x, position_y - 1] <- 1
      position_x <- position_x + 1
      
    }else if(wait_time_x[position_x, position_y] == 0){
      
      # go right (no wait)
      route_x[position_x, position_y] <- 1
      position_y <- position_y + 1
      
    }else if(wait_time_y[position_x, position_y] == 0){
      
      # go down (no wait)
      route_y[position_x, position_y] <- 1
      position_x <- position_x + 1
      
    }
  }
  
  list(route_x = route_x, route_y = route_y)
}


#' stategy: "conditioinal wait"
#' 
#' @param wait_time_x a matrix of the wait time to go right at each intersection
#' @param wait_time_y a matrix of the wait time to go down at each intersection
#' @param crossroad_standard_x the maximum wait time (for red light) to go right at each intersection
#' @param crossroad_standard_y the maximum wait time (for red light) to go down at each intersection
#' @arg1 additional argument placeholder 1
#' @arg2 additional argument placeholder 2
#' 
strategy_conditional_wait <- function(
  wait_time_x, 
  wait_time_y,
  crossroad_standard_x,
  crossroad_standard_y,
  arg1 = NULL,
  arg2 = NULL
){
  
  # whether one goes right at crossroad
  route_x <- matrix(0, ncol = road_dim, nrow = road_dim)
  # whether one goes down at crossroad
  route_y <- matrix(0, ncol = road_dim, nrow = road_dim)
  
  position_x <- 1
  position_y <- 1
  
  # the threshold for the ratio of current wait time to maximum wait time
  threshold1 <- arg1
  # the threshold for the ratio of maximum wait time of the two crossing roads
  threshold2 <- arg2
  
  while(TRUE){
    
    if(position_x == road_dim + 1 & position_y == road_dim + 1){
      
      # the ending status
      break
      
    }else if(position_x == road_dim + 1){
      
      # reachcing the boundary at the bottom
      route_x[position_x - 1, position_y] <- 1
      position_y <- position_y + 1
      
    }else if(position_y == road_dim + 1){
      
      # reachcing the boundary on the right
      route_y[position_x, position_y - 1] <- 1
      position_x <- position_x + 1
      
    }else if(wait_time_x[position_x, position_y] == 0){
      
      if(
        wait_time_y[position_x, position_y] / crossroad_standard_x[position_x, position_y] < threshold1 &
        crossroad_standard_x[position_x, position_y] / crossroad_standard_y[position_x, position_y] > threshold2
      ){
        
        # go down even though you have to wait
        # because you don't have to wait for too long
        route_y[position_x, position_y] <- 1
        position_x <- position_x + 1
        
      }else{
        # go right (no wait)
        route_x[position_x, position_y] <- 1
        position_y <- position_y + 1
      }
      
    }else if(wait_time_y[position_x, position_y] == 0){
      
      if(
        wait_time_x[position_x, position_y] / crossroad_standard_y[position_x, position_y] < threshold1 &
        crossroad_standard_y[position_x, position_y] / crossroad_standard_x[position_x, position_y] > threshold2
      ){
        
        # go right even though you have to wait
        # because you don't have to wait for too long
        route_x[position_x, position_y] <- 1
        position_y <- position_y + 1
        
      }else{
        # go down (no wait)
        route_y[position_x, position_y] <- 1
        position_x <- position_x + 1
      }
    }
    
  }
  
  list(route_x = route_x, route_y = route_y)
}


#' stategy: "ride along main street"
#' 
#' @param wait_time_x a matrix of the wait time to go right at each intersection
#' @param wait_time_y a matrix of the wait time to go down at each intersection
#' @param crossroad_standard_x the maximum wait time (for red light) to go right at each intersection
#' @param crossroad_standard_y the maximum wait time (for red light) to go down at each intersection
#' @arg1 additional argument placeholder 1
#' @arg2 additional argument placeholder 2
#' 
strategy_ride_along_main_street <- function(
  wait_time_x, 
  wait_time_y,
  crossroad_standard_x,
  crossroad_standard_y,
  arg1 = NULL,
  arg2 = NULL
){
  
  # whether one goes right at crossroad
  route_x <- matrix(0, ncol = road_dim, nrow = road_dim)
  # whether one goes down at crossroad
  route_y <- matrix(0, ncol = road_dim, nrow = road_dim)
  
  position_x <- 1
  position_y <- 1
  
  while(TRUE){
    
    if(position_x == road_dim + 1 & position_y == road_dim + 1){
      
      # the ending status
      break
      
    }else if(position_x == road_dim + 1){
      
      # reachcing the boundary at the bottom
      route_x[position_x - 1, position_y] <- 1
      position_y <- position_y + 1
      
    }else if(position_y == road_dim + 1){
      
      # reachcing the boundary on the right
      route_y[position_x, position_y - 1] <- 1
      position_x <- position_x + 1
      
    }else if(position_x == which.max(road_y$importance)){
      
      # on the vertical main road
      # go down
      route_y[position_x, position_y] <- 1
      position_x <- position_x + 1
      
    }else if(position_y == which.max(road_x$importance)){
      
      # on the horizontal main road
      # go right
      route_x[position_x, position_y] <- 1
      position_y <- position_y + 1
      
    }else if(wait_time_x[position_x, position_y] == 0){
      
      # go right (no wait)
      route_x[position_x, position_y] <- 1
      position_y <- position_y + 1
      
    }else if(wait_time_y[position_x, position_y] == 0){
      
      # go down (no wait)
      route_y[position_x, position_y] <- 1
      position_x <- position_x + 1
      
    }
  }
  
  list(route_x = route_x, route_y = route_y)
}
