local LOCATION_SCALING_FACTOR_INV=89.83204953368922

function wrap_180(angle)
    local res = wrap_360(angle)
    if res > 180 then
       res = res - 360
    end
    return res
end

function wrap_360(angle)
    local res = math.fmod(angle, 360.0)
     if res < 0 then
         res = res + 360.0
     end
     return res
 end

function longitude_scale(lat)
    local DEG_TO_RAD = math.pi / 180  
    local scale = math.cos(lat * (1.0e-7 * DEG_TO_RAD))
    return math.max(scale, 0.01)
end

function limit_latitude(lat)
    if lat > 900000000 then
        lat = 1800000000 - lat
    elseif lat < -900000000 then
        lat = -(1800000000 + lat)
    end
    return lat
end

function wrap_longitude(lon)
    if lon > 1800000000 then
        lon = lon - 3600000000
    elseif lon < -1800000000 then
        lon = lon + 3600000000
    end
    return lon
end

 -- Extrapolate latitude/longitude given bearing and distance
function offset_bearing(lat, lng, bearing_deg, distance)
    local radians = math.rad  
    local ofs_north = math.cos(math.rad(bearing_deg)) * distance
    local ofs_east  = math.sin(math.rad(bearing_deg)) * distance
    local dlat = ofs_north * LOCATION_SCALING_FACTOR_INV
    local dlng = (ofs_east * LOCATION_SCALING_FACTOR_INV) / longitude_scale(lat + dlat / 2)
    lat = lat + dlat
    lat = limit_latitude(lat)
    lng = wrap_longitude(dlng + lng)
    return lat, lng
end


function location_project(loc1, bearing_deg, distance)
    -- Create a copy of the location
    
    local loc2 = Location()
    --loc2=loc1
    --loc2:offset_bearing(bearing_deg, distance) 
    local lat, lon=offset_bearing(loc1:lat(), loc1:lng(), bearing_deg, distance)
    loc2:lat(lat)
    loc2:lng(lon)
    loc2:alt(loc1:alt())
    gcs:send_text(0, string.format("IN: Lat: %.2f, Lon: %.2f", loc1:lat(),loc1:lng()))
    gcs:send_text(0, string.format("Dist: %.2f, Bear: %.2f", distance,bearing_deg)) 
    gcs:send_text(0, string.format("Out: Lat: %.2f, Lon: %.2f", loc2:lat(),loc2:lng()))  
    return loc2
end


function update()
    --gcs:send_text(0, "Lua running")
    -- Check if the 'avoid' function is available
    if avoid == nil then
        gcs:send_text(0, "AP_Avoidance singleton not available")
        return
    end

    
    local current_loc = ahrs:get_position()
    local ground_course_deg = wrap_180(math.deg(ahrs:groundspeed_vector():angle()))
    if not current_loc then
        gcs:send_text(0, "Not current position")
        return update, 100
    else
        local projected_loc = location_project(current_loc, ground_course_deg, 50)
    end

    return update, 100
end

return update,100

