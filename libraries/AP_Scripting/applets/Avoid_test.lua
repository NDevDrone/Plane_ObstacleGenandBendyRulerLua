gcs:send_text(0, "Lua Script init")

function update()
    --gcs:send_text(0, "Lua running")
    -- Check if the 'avoid' function is available
    if avoid == nil then
        gcs:send_text(0, "AP_Avoidance singleton not available")
        return
    end
    -- Get total number of obstacles
    local num_obstacles = avoid:num_obstacles()
    -- Check if there is any obstacle
    if num_obstacles == 0 then
        gcs:send_text(0, "No obstacles detected")
    else
   	 gcs:send_text(0, string.format("Num of Obstacle: %d", num_obstacles))
        -- Recorrer cada obstáculo y obtener sus datos
        for i = 0, num_obstacles - 1 do
            -- Obtener la ubicación del obstáculo
            local obstacle_loc = avoid:get_obstacle_loc(i)
            local lat = obstacle_loc:lat() * 1e-7
            local lon = obstacle_loc:lng() * 1e-7
            local alt = obstacle_loc:alt() * 1e-2       
            -- Obtener la velocidad del obstáculo
            local obstacle_vel = avoid:get_obstacle_vel(i)
            local vx = obstacle_vel:x()
            local vy = obstacle_vel:y()
            local vz = obstacle_vel:z()        
            -- Obtener el ID del obstáculo
            local obstacle_id = avoid:get_obstacle_id(i)        
            -- Obtener el timestamp del obstáculo
            local obstacle_time = avoid:get_obstacle_time(i)        
            -- Enviar la información al GCS
            gcs:send_text(0, string.format("Obstacle %d: Lat: %.6f, Lon: %.6f, Alt: %.2f", obstacle_id, lat, lon, alt))
            gcs:send_text(0, string.format("Velocity: vx: %.2f, vy: %.2f, vz: %.2f", vx, vy, vz))
            --gcs:send_text(0, string.format("Timestamp: %d", obstacle_time))
        end
    end
   
    return update, 100
end

return update,100
