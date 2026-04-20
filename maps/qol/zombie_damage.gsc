#include common_scripts\utility; 

zombie_damage_init()
{ 
	if( GetDvar( "3hit_enable" ) == "" )
	{
		SetDvar( "3hit_enable", "0" );
	}
	thread infected_dmg(); 
}

infected_dmg()
{
	while(1)
	{
		infected = GetAiArray( "axis" );
		
		is_enabled = (GetDvar( "3hit_enable" ) == "1");
		
		for( i=0;i<infected.size;i++ )
		{
			if( is_true( infected[i].meleeDamage ) )
			{
				if( is_enabled )
				{
					infected[i].meleeDamage = 45;
				}
				else
				{
					infected[i].meleeDamage = 50;
				}
			}
		}
		wait 0.05;
	}
}