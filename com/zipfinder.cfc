<cfcomponent>	
    <cfscript>
      param name="piDivRad" default="0.0174";	// Pi divided by 180
      param name="latitudeMiles"	default="69.1";		// Number of miles per degree of latitude.  
      param name="earthRadius"	default="3956";		// Radius of the earth in miles
      </cfscript>
	<cffunction name="zipToLL" access="public">
		<!--- 
			This is a helper function.  Given a zip code, it will look up the
			relevant lats and longs (and their corresponding values in radians)
			and then pass back a structure containing this information --->
			
		<cfargument name="zip" type="string" required="true">
		
		<!--- gets a new coordinate pair --->
		<cfset cp = getNewCoordinate()>	
		
		<cfquery name="qGetLL" >
		select latitude,longitude,rlatitude,rlongitude from zips
		where zip = <cfqueryparam value="#zip#" cfsqltype="CF_SQL_CHAR">
		</cfquery>
		
		<cfif qGetLL.recordcount gt 0>
			<cfset cp.latitude		= qGetLL.latitude>
			<cfset cp.longitude		= qGetLL.longitude>
			<cfset cp.rlatitude 	= qGetLL.rlatitude>
			<cfset cp.rlongitude 	= qGetLL.rlongitude>
		</cfif>
		
		<cfreturn cp>
    </cffunction>

	<!--- +++++++++++++++++++++++++++++++++++++++++++++ --->		
	
	<cffunction name="getNewCoordinate" access="public">
		<!--- 
			Basically, this is a constructor that gives us a blank coordinate pair.
		 --->
		 
		<cfset retVal 				= structNew()>
		<cfset retVal.latitude		= 0>
		<cfset retVal.longitude		= 0>
		<cfset retVal.rlatitude		= 0>
		<cfset retVal.rlongitude	= 0>
		<cfreturn retVal>		
    </cffunction>
	
	
	<!--- +++++++++++++++++++++++++++++++++++++++++++++ --->		
	
	<cffunction name="squareSearch" access="public">	
		<!--- 
			This function performs a proximity search by building out a rectangle
			from a given set of coordinates, and then returning matching items that
			fall within that area.  It is not the most accurate way to search, but 
			for smaller distances, it is okay.  It is also very fast. 
		--->
		<cfargument name="radius" 	type="numeric" 	required="true">
		<cfargument name="zip" 		type="string" 	required="true">
		
		<cfset radius 		= arguments.radius>
		<cfset zip			= arguments.zip>		
		<cfset z1			= zipToLL(zip)>
		
		<cfset lat_miles	= latitudeMiles>	<!--- You can change this if you need more precision --->
		<cfset lon_miles	= abs(lat_miles * cos(z1.latitude * piDivRad))>
		<cfset lat_degrees	= radius / lat_miles>
		<cfset lon_degrees	= radius / lon_miles>
		
		<!--- This is where we calculate the bounds of the search rectangle --->
		<cfset lat1			= z1.latitude - lat_degrees>
		<cfset lat2			= z1.latitude + lat_degrees>
		<cfset lon1			= z1.longitude - lon_degrees>
		<cfset lon2			= z1.longitude + lon_degrees>
		
		
		<!--- 
			To perform the search, we're going to use trigonometry.  Remember the equation, x^2 + y^2 = z^2, 
			aka the Pythazizzle Thizzle? If you look closely, you can see that we are using that in order 
			to calculate the distance (dist) in the query below.
			
			This is good, because it is a fast calculation.  But, it is bad because it is calculating the 
			distance as if it were a line.  If the world were flat, this would be perfect.  But, since it isn't,
			this will start to show errors the larger the radius gets.
			
			Still, for your applications, the errors might be small enough to justify the BLAZING SPEED.
		 --->
		<cfquery name="qSquareSearch" >
		select 	distinct(zip), state, city,
			SQRT(
					SQUARE(#lat_miles# * (latitude - (#z1.latitude#))) 
					+
					square(#lon_miles# * (longitude - (#z1.longitude#)))
				) as dist
		from 	zips
		where
			latitude between #lat1# AND #lat2#
			AND
			longitude between #lon1# AND #lon2#
			
		order by dist asc
		</cfquery>
		
		<!--- 
			This is just a quick filter query that will remove some of the zips that get erroneously
			included in the result set.  This helps to offset the errors that this method introduces, 
			but only just a little.
		 --->
		<cfquery name="qRefine" dbtype="query">
		select * from qSquareSearch where dist < <cfqueryparam value="#radius#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
		
		<cfreturn qRefine>	
    </cffunction>
	
	<!--- +++++++++++++++++++++++++++++++++++++++++++++ --->	
			
		
	<cffunction name="haversineSearch" access="public">
		<!---
		  This performs a proximity search by using the Haversine Formula.  
		  This is a much more accurate way of doing it, but it is also a lot slower.
		  
			//The Haversine Formula
		   		dLon (difference in longitude)	= longitude 2 - longitude 1
		        dLat (difference in latitude)	= latitude 2 - latitude 1
				
		        a = sin^2(dLat/2) + cos(latitude 1) * cos(latitude 2) * sin^2(dLon /2)
		        c = 2 * arcsin(min(1,sqrt(a)))
		        distance = radius * c
		--->
		
		<cfargument name="zip" 		type="string" 	required="true">
		<cfargument name="radius" 	type="numeric" 	required="true">
		<cfargument name="verticalID" type='numeric' required="false">
		
		<cfset radius 		= arguments.radius>
		<cfset zip			= arguments.zip>		
		<cfset z1			= zipToLL(zip)>
		
		<cfquery name="qHaversineSearch" >
		SELECT  distinct(zip), county, state, citymixedcase as City,latitude, longitude,
		
			(
				#earthRadius# * 2 * 
					ASIN
						(	 
							(SQRT
								(
								POWER(SIN(((RLATITUDE-#z1.RLATITUDE#))/2),2) 
								+ COS(#z1.RLATITUDE#) 
								* COS(RLATITUDE)
								* POWER(SIN(((abs(RLONGITUDE)- (#z1.RLONGITUDE#)))/2),2) 
								)
							) 
						) 
			) AS dist
		
			 
		from zips
		
		<cfif isdefined('arguments.verticalID') and arguments.verticalID NEQ "">
			
		LEFT JOIN companies_listings on zips.zip = companies_listings.listingZipCode
		</cfif>
		
		WHERE
			(#earthRadius# * 2 * 
				ASIN
					( 
						(SQRT
							( 
							POWER(SIN(((RLATITUDE-#z1.RLATITUDE#))/2),2) 
							+ COS(#z1.RLATITUDE#) 
							* COS(RLATITUDE) 
		                  	* POWER(SIN(((abs(RLONGITUDE)-(#z1.RLONGITUDE#)))/2),2) )
						) 
					) 
			) < <cfqueryparam value="#radius#" cfsqltype="CF_SQL_INTEGER"> and PrimaryRecord='P'
			<cfif isdefined('arguments.verticalID') and arguments.verticalID NEQ "">
			and companies_listings.verticalID = <cfqueryparam value="#arguments.verticalID#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		ORDER BY dist
		</cfquery>	
	
		<cfreturn qHaversineSearch>
    </cffunction>
    
</cfcomponent>