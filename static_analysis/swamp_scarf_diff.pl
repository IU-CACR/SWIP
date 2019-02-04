#!/usr/bin/perl -w

###################################### imports #######################################
use strict;
use FindBin;
use lib "$FindBin::Bin";
use Getopt::Long;
use ScarfXmlReader;
#use ScarfJSONReader;
use Storable 'dclone';
use Data::Dumper;



################################## DIFF finder ########################################
sub diffMetric
{
    my ($root, $cmp, $data) = @_;

    my $countDif;
    my $rootCount;
    my $cmpCount;
    foreach my $type (keys %{$root}) {
	foreach my $source (keys %{$root->{$type}}) {
	    foreach my $class (keys %{$root->{$type}{$source}}) {
		foreach my $method (keys %{$root->{$type}{$source}{$class}}) {
		    foreach my $value (keys %{$root->{$type}{$source}{$class}{$method}}) {
			if (defined $root->{$type}{$source}{$class}{$method}{$value}) {
			    $rootCount = scalar @{$root->{$type}{$source}{$class}{$method}{$value}};
			} else {
			    $rootCount = 0;
			}
			if (defined $cmp->{$type}{$source}{$class}{$method}{$value}) {
			    $cmpCount = scalar @{$cmp->{$type}{$source}{$class}{$method}{$value}};
			} else {
			    $cmpCount = 0;
			}
			$countDif = $rootCount - $cmpCount;
			if ( $countDif > 0 ) {
	                    $data->{removedMetrics}{$type}{$source}{$class}{$method}{$value} = abs $countDif;
			} elsif ( $countDif < 0 ) {
			    $data->{newMetrics}{$type}{$source}{$class}{$method}{$value} = abs $countDif;
			}
			delete $cmp->{$type}{$source}{$class}{$method}{$value};
		    }
		}
	    }
	}
    }
    foreach my $type (keys %{$cmp}) {
	foreach my $source (keys %{$cmp->{$type}}) {
	    foreach my $class (keys %{$cmp->{$type}{$source}}) {
		foreach my $method (keys %{$cmp->{$type}{$source}{$class}}) {
		    foreach my $value (keys %{$cmp->{$type}{$source}{$class}{$method}}) {
			$data->{newMetrics}{$type}{$source}{$class}{$method}{$value} = scalar @{$cmp->{$type}{$source}{$class}{$method}{$value}};
		    }
		}
	    }
	}
    }
}



sub diff
{
    my ($root, $cmp, $ret, $data) = @_;

    my $countDif;
    my $rootCount;
    my $cmpCount;
    if ($ret == 0) {
	foreach my $Group (keys %{$root}){
	    if (exists $root->{$Group}) {
		$rootCount = scalar @{$root->{$Group}} ;
	    } else {
		$rootCount = 0;
	    }
	    if (exists $cmp->{$Group}) {
		$cmpCount = scalar @{$cmp->{$Group}};
	    } else {
		$cmpCount = 0;
	    }
	    $countDif = $rootCount - $cmpCount ;
	    if ( $countDif > 0 ) {
		$data->{removed}{$Group} = abs $countDif;
	    } elsif ( $countDif < 0 ) {
		$data->{new}{$Group} = abs $countDif;
	    }
	    delete $cmp->{$Group};
	}
        foreach my $Group (keys %{$cmp}){
	    $data->{new}{$Group} = scalar @{$cmp->{$Group}};
	}
    } elsif ($ret == 1) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		if (exists $root->{$Group}{$Code}) {
		    $rootCount = scalar @{$root->{$Group}{$Code}} ;
		} else {
		    $rootCount = 0;
		}
		if (exists $cmp->{$Group}{$Code}) {
		    $cmpCount = scalar @{$cmp->{$Group}{$Code}};
		} else {
		    $cmpCount = 0;
		}
		$countDif = $rootCount - $cmpCount ;
	        if ( $countDif > 0 ) {
		   $data->{removed}{$Group}{$Code} = abs $countDif;
		} elsif ( $countDif < 0 ) {
		    $data->{new}{$Group}{$Code} = abs $countDif;
		}
		delete $cmp->{$Group}{$Code};
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
		$data->{new}{$Group}{$Code} = scalar @{$cmp->{$Group}{$Code}};
	    }
	}
    } elsif ($ret == 2) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    if (exists $root->{$Group}{$Code}{$Source}) {
			$rootCount = scalar @{$root->{$Group}{$Code}{$Source}} ;
		    } else {
			$rootCount = 0;
		    }
		    if (exists $cmp->{$Group}{$Code}{$Source}) {
			$cmpCount = scalar @{$cmp->{$Group}{$Code}{$Source}};
		    } else {
			$cmpCount = 0;
		    }
		    $countDif = $rootCount - $cmpCount ;
		    if ( $countDif > 0 ) {
			$data->{removed}{$Group}{$Code}{$Source} = abs $countDif;
		    } elsif ( $countDif < 0 ) {
			$data->{new}{$Group}{$Code}{$Source} = abs $countDif;
		    }
		    delete $cmp->{$Group}{$Code}{$Source};
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
			$data->{new}{$Group}{$Code}{$Source} = scalar @{$cmp->{$Group}{$Code}{$Source}};
		}
	    }
	}
    } elsif ($ret == 3) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    foreach my $StartLine (keys %{$root->{$Group}{$Code}{$Source}}) {
			if (exists $root->{$Group}{$Code}{$Source}{$StartLine}) {
			    $rootCount = scalar @{$root->{$Group}{$Code}{$Source}{$StartLine}} ;
			} else {
			    $rootCount = 0;
			}
			if (exists $cmp->{$Group}{$Code}{$Source}{$StartLine}) {
			    $cmpCount = scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}};
			} else {
			    $cmpCount = 0;
			}
			$countDif = $rootCount - $cmpCount ;
			if ( $countDif > 0 ) {
			    $data->{removed}{$Group}{$Code}{$Source}{$StartLine} = abs $countDif;
			} elsif ( $countDif < 0 ) {
			    $data->{new}{$Group}{$Code}{$Source}{$StartLine} = abs $countDif;
			}
			delete $cmp->{$Group}{$Code}{$Source}{$StartLine};
		    }
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
                    foreach my $StartLine (keys %{$cmp->{$Group}{$Code}{$Source}}) {
			$data->{new}{$Group}{$Code}{$Source}{$StartLine} = scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}};
		    }
		}
	    }
	}

    } elsif ($ret == 4) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    foreach my $StartLine (keys %{$root->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}}) {
			    if (exists $root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}) {
				$rootCount = scalar @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}} ;
			    } else {
				$rootCount = 0;
			    }
			    if (exists $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}) {
				$cmpCount = scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}};
			    } else {
				$cmpCount = 0;
			    }
			    $countDif = $rootCount - $cmpCount ;
			    if ( $countDif > 0 ) {
				$data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine} = abs $countDif;
			    } elsif ( $countDif < 0 ) {
				$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine} = abs $countDif;
			    }
			    delete $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine};
			}
		    }
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
                    foreach my $StartLine (keys %{$cmp->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}}) {
			    $data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine} = scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}};
			}
		    }
		}
	    }
	}

    } elsif ($ret == 5) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    foreach my $StartLine (keys %{$root->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				if (exists $root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}) {
				    $rootCount = scalar @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}} ;
				} else {
				    $rootCount = 0;
				}
				if (exists $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}) {
				    $cmpCount = scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}};
				} else {
				   $cmpCount = 0;
				}
				$countDif = $rootCount - $cmpCount ;
				if ( $countDif > 0 ) {
				    $data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn} = abs $countDif;
				} elsif ( $countDif < 0 ) {
				    $data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn} = abs $countDif;
				}
				delete $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn};
			    }
			}
		    }
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
                    foreach my $StartLine (keys %{$cmp->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}
							= scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}};
			    }
			}
		    }
		}
	    }
	}
    } elsif ($ret == 6) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    foreach my $StartLine (keys %{$root->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				foreach my $EndColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}}) {
				    if (exists $root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}) {
					$rootCount = scalar @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}} ;
				    } else {
					$rootCount = 0;
				    }
				    if (exists $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}) {
					$cmpCount = scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}};
				    } else {
					$cmpCount = 0;
				    }
				    $countDif = $rootCount - $cmpCount ;
				    if ( $countDif > 0 ) {
					$data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn} = abs $countDif;
				    } elsif ( $countDif < 0 ) {
					$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn} = abs $countDif;
				    }
				    delete $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn};
				}
			    }
			}
		    }
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
                    foreach my $StartLine (keys %{$cmp->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				foreach my $EndColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}}) {
				    $data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}
							= scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}};
				}
			    }
			}
		    }
		}
	    }
	}
    } elsif ($ret == 7) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    foreach my $StartLine (keys %{$root->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				foreach my $EndColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}}) {
				    foreach my $rootIndex ( @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}) {
					my $match;
					my $Secondary = @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}[$rootIndex];
					if ( exists $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn} ) {
					    foreach my $cmpIndex ( 0 .. scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}} - 1) {
						my $cmpSecondary = @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}[$cmpIndex];
						$match = 1;
						if ( scalar @{$Secondary->{CweIds}} !=  scalar @{$cmpSecondary->{CweIds}}) {
						    $match = 0;
						    next;
						}
						for my $rootCwe (@{$Secondary->{CweIds}}) {
						    $match = 0;
						    for my $cmpCwe (@{$cmpSecondary->{CweIds}}) {
						        if ( $rootCwe == $cmpCwe ) {
							    $match = 1;
							    last;
							}
						    }
						    if ($match == 0){
							last;
						    } else {
							next;
						    }
						}
						if ($match == 1) {
						    $countDif = scalar @{$Secondary->{BugId}} - scalar @{$cmpSecondary->{BugId}};
						    my $newSecondary = $Secondary;
						    $newSecondary->{BugId} = abs $countDif;
						    if ( $countDif > 0 ) {
							push @{$data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $newSecondary;
							splice @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}},$cmpIndex, 1;
							last;
						    } elsif ( $countDif < 0 ) {
							push @{$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $newSecondary;
							splice @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $cmpIndex, 1;
							last;
						    } else {
							splice @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $cmpIndex, 1;
							last;
						    }
						} else {
						    next;
						}
					    }
					    if ($match == 1) {
						next;
					    }
					} else {
					    $match = 0;
					}


					if ($match == 0) {
					    my $newSecondary = $Secondary;
					    $newSecondary->{BugId} = scalar @{$Secondary->{BugId}};
					    push @{$data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $newSecondary;
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
                    foreach my $StartLine (keys %{$cmp->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				foreach my $EndColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}}) {
				    foreach my $cmpSecondarys ( @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}) {
					$cmpSecondarys->{BugId} = scalar @{$$cmpSecondarys->{BugId}};
					push @{$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $cmpSecondarys;
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    } elsif ($ret == 8) {
	foreach my $Group (keys %{$root}){
	    foreach my $Code (keys %{$root->{$Group}}){
		foreach my $Source (keys %{$root->{$Group}{$Code}}) {
		    foreach my $StartLine (keys %{$root->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				foreach my $EndColumn (keys %{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}}) {
				    foreach my $rootIndex (0 .. scalar @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}} - 1) {
					my $match;
					my $Secondary = @{$root->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}[$rootIndex];
					if ( exists $cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn} ) {
					    foreach my $cmpIndex ( 0 .. scalar @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}} - 1) {
						my $cmpSecondary = @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}[$cmpIndex];
						$match = 1;
						if ( scalar @{$Secondary->{CweIds}} !=  scalar @{$cmpSecondary->{CweIds}}) {
						    $match = 0;
						    next;
						}
						for my $rootCwe (@{$Secondary->{CweIds}}) {
						    $match = 0;
						    for my $cmpCwe (@{$cmpSecondary->{CweIds}}) {
						        if ( $rootCwe == $cmpCwe ) {
							    $match = 1;
							    last;
							}
						    }
						    if ($match == 0){
							last;
						    } else {
							next;
						    }
						}
						if($match == 1) {
						    if ( scalar @{$Secondary->{Methods}} != scalar @{$cmpSecondary->{Methods}} ) {
							$match = 0;
							next;
						    }
						    for my $rootMethods (@{$Secondary->{Methods}}) {
							$match = 0;
							for my $cmpMethods (@{$cmpSecondary->{Methods}}) {
							    if ( $rootMethods eq $cmpMethods ) {
								$match = 1;
								last;
							    }
							}
							if ($match == 0){
							    last;
							} else {
							    next;
							}
						    }
						} else {
						    next;
						}
						if ($match == 1) {
						    $countDif = scalar @{$Secondary->{BugId}} - scalar @{$cmpSecondary->{BugId}};
						    my $newSecondary = $Secondary;
						    $newSecondary->{BugId} = abs $countDif;
						    if ( $countDif > 0 ) {
							push @{$data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $newSecondary;
							splice @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}},$cmpIndex, 1;
							last;
						    } elsif ( $countDif < 0 ) {
							push @{$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $newSecondary;
							splice @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $cmpIndex, 1;
							last;
						    } else {
							splice @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $cmpIndex, 1;
							last;
						    }
						} else {
						    next;
						}
					    }
					    if ($match == 1) {
						next;
					    }
					} else {
					    $match = 0;
					}


					if ($match == 0) {
					    my $newSecondary = $Secondary;
					    $newSecondary->{BugId} = scalar @{$Secondary->{BugId}};
					    push @{$data->{removed}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $newSecondary;
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
        foreach my $Group (keys %{$cmp}){
            foreach my $Code (keys %{$cmp->{$Group}}){
                foreach my $Source (keys %{$cmp->{$Group}{$Code}}) {
                    foreach my $StartLine (keys %{$cmp->{$Group}{$Code}{$Source}}) {
			foreach my $EndLine (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}}) {
			    foreach my $StartColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}}) {
				foreach my $EndColumn (keys %{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}}) {
				    foreach my $cmpSecondarys ( @{$cmp->{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}) {
					$cmpSecondarys->{BugId} = scalar @{$cmpSecondarys->{BugId}};
					push @{$data->{new}{$Group}{$Code}{$Source}{$StartLine}{$EndLine}{$StartColumn}{$EndColumn}}, $cmpSecondarys;
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    } else {
	die "invalid options\n";
    }
}



############################### Metric Callbacks
sub rootMetric
{
    my ($metric, $dataHash) = @_;
    my $ret = $$dataHash->{ret};
    my ($class, $method, $source, $value, $type);
    if (exists $metric->{Class}) {
	$class = $metric->{Class};
    } else {
	$class = "undefined";
    }
    if (exists $metric->{Method}) {
	$method = $metric->{Method};
    } else {
	$method = "undefined";
    }
    if (exists $metric->{Source}) {
	$source = $metric->{Source};
    } else {
	$source = "undefined";
    }
    if (exists $metric->{Value}) {
	$value = $metric->{Value};
    } else {
	$value = "undefined";
    }
    if (exists $metric->{Type}) {
	$type = $metric->{Type};
    } else {
	$type = "undefined";
    }
    push @{$$dataHash->{rootMetrics}{$type}{$source}{$class}{$method}{$value}}, $metric->{MetricId};
    return;
}



sub cmpMetric
{
    my ($metric, $dataHash) = @_;
    my $ret = $$dataHash->{ret};
    my ($class, $method, $source, $value, $type);
    if (exists $metric->{Class}) {
	$class = $metric->{Class};
    } else {
	$class = "undefined";
    }
    if (exists $metric->{Method}) {
	$method = $metric->{Method};
    } else {
	$method = "undefined";
    }
    if (exists $metric->{Source}) {
	$source = $metric->{Source};
    } else {
	$source = "undefined";
    }
    if (exists $metric->{Value}) {
	$value = $metric->{Value};
    } else {
	$value = "undefined";
    }
    if (exists $metric->{Type}) {
	$type = $metric->{Type};
    } else {
	$type = "undefined";
    }
    push @{$$dataHash->{cmpMetrics}{$type}{$source}{$class}{$method}{$value}}, $metric->{MetricId};
    return;
}



############################### Bug Callback for root file (arg1) #############################################################################
sub rootBug
{
    my ($bugHash, $dataHash) = @_;
    my $ret = $$dataHash->{ret};
    my $options = $$dataHash->{options};
    my $code;
    my $group;
    my $sourceFile;
    my $startLine;
    my $endLine;
    my $startCol;
    my $endCol;
    my @methods;
    my @cwe;

    if ($ret >= 0) {
	if ( exists $bugHash->{BugGroup} and $options->{bug_group} ) {
	    $group = $bugHash->{BugGroup};
	} else {
	    $group = "undefined";
	}
    } else {
	return;
    }

    if ($ret > 0) {
	if ( exists $bugHash->{BugCode} and $options->{bug_code} ) {
	    $code = $bugHash->{BugCode};
	} else {
	    $code = "undefined";
	}
    } else {
	push @{$$dataHash->{root}{$group}}, $bugHash->{BugId};
	return;
    }

    if ($options->{only_primary}) {
	for my $location(@{$bugHash->{BugLocations}}) {
	    if ( $location->{primary} ) {
		if ( $ret > 1 ) {
		if ( exists $location->{SourceFile} and $options->{source_file} ) {
			$sourceFile = $location->{SourceFile};
		    } else {
			$sourceFile = "undefined";
		    }
		} else {
		    push @{$$dataHash->{root}{$group}{$code}}, $bugHash->{BugId};
		    return;
		}


		if ( $ret > 2 ) {
		    if ( exists $location->{StartLine} and $options->{start_line} ) {
			$startLine = $location->{StartLine};
		    } else {
			$startLine = "undefined";
		    }
		} else {
		    push @{$$dataHash->{root}{$group}{$code}{$sourceFile}}, $bugHash->{BugId};
		    return;
		}

		if ( $ret > 3 ) {
		    if ( exists $location->{EndLine} and $options->{end_line} ) {
			$endLine = $location->{EndLine};
		    } else {
			$endLine = "undefined";
		    }
		} else {
		    push @{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}}, $bugHash->{BugId};
		    return;
		}

		if ( $ret > 4 ) {
		    if ( exists $location->{StartColumn} and $options->{start_column} ) {
			$startCol = $location->{StartColumn};
		    } else {
			$startCol = "undefined";
		    }
		} else {
		    push @{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}}, $bugHash->{BugId};
		    return;
		}

		if ( $ret > 5 ) {
		    if ( exists $location->{EndColumn} and $options->{end_column} ) {
			$endCol = $location->{EndColumn};
		    } else {
			$endCol = "undefined";
		    }
		} else {
		    push @{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}}, $bugHash->{BugId};
		    return;
		}
	    }
	}
    }


    if ( $ret > 6 ) {
	if ( not exists $$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} ) {
	    $$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} = [];
	}
	my $secondaryHash = {};
	$secondaryHash->{BugId} = [$bugHash->{BugId}];
	if ( defined $bugHash->{CweIds} and $options->{cwe}) {
	    push @{$secondaryHash->{CweIds}}, @{$bugHash->{CweIds}};
	} else {
	    $secondaryHash->{CweIds} = [];
	}

	if ( $ret > 7 ) {
	    if ( defined $bugHash->{Methods} and $options->{methods}) {
		$secondaryHash->{Methods} = [];
		for my $method ( @{$bugHash->{Methods}} ) {
		    push @{$secondaryHash->{Methods}}, $method->{name};
		}
	    } else {
		$secondaryHash->{Methods} = [];
	    }
	} else {
	    if ( exists $$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} ) {
		for my $secondary (@{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}) {
		    my $match = 1;
		    if (@{$secondary->{CweIds}}) {
			for my $cwe ($secondary->{CweIds}) {
			    for my $datacwe (@{$secondaryHash->{CweIds}}) {
				if ( $cwe != $datacwe ) {
				   $match = 0;
				    last;
				}
			    }
			    if (not $match){
				last;
			    }
			}
		    } elsif (@{$secondaryHash->{CweIds}}) {
		        $match = 0;
		    }
		    if ( $match ) {
			push @{$secondary->{BugId}}, $bugHash->{BugId};
			return;
		    }
		}
	    }
	    push @{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}, $secondaryHash;
	    return;
	}

	if ( $ret > 8 ) {
	    #do nothing
	} else {
	    if ( exists $$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} ) {
		for my $secondary (@{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}) {
		    my $match = 1;
		    if (@{$secondary->{CweIds}}) {
			for my $cwe ($secondary->{CweIds}) {
			    for my $datacwe (@{$secondaryHash->{CweIds}}) {
				if ( $cwe != $datacwe ) {
				    $match = 0;
				    last;
				}
			    }
			    if (not $match){
				last;
			    }
			}
		    } elsif ( @{$secondaryHash->{CweIds}}) {
			$match = 0;
		    }
		    if ( $match ) {
			if (@{$secondary->{Methods}}) {
			    for my $methods (@{$secondary->{Methods}}) {
				for my $datamethods (@{$secondaryHash->{Methods}}) {
				    if ( not ($methods eq $datamethods) ) {
					$match = 0;
					last;
				    }
				}
				if (not $match){
				    last;
				}
			    }
			} elsif (@{$secondaryHash->{Methods}}) {
			    $match = 0;
			}

			if ( $match ) {
			    push @{$secondary->{BugId}}, $bugHash->{BugId};
			    return;
			}
		    }
		}
	    }
	    push @{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}, $secondaryHash;
	    return;
	}

    } else {
	push @{$$dataHash->{root}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}, $bugHash->{BugId};
	return;
    }


    return;
}



############################### Bug Callback for cmp file (arg2) #############################################################################
sub cmpBug
{
    my ($bugHash, $dataHash) = @_;
    my $ret = $$dataHash->{ret};
    my $options = $$dataHash->{options};
    my $code;
    my $group;
    my $sourceFile;
    my $startLine;
    my $endLine;
    my $startCol;
    my $endCol;
    my @methods;
    my @cwe;

    if ($ret >= 0) {
	if ( exists $bugHash->{BugGroup} and $options->{bug_group} ) {
	    $group = $bugHash->{BugGroup};
	} else {
	    $group = "undefined";
	}
    } else {
	return;
    }

    if ($ret > 0) {
	if ( exists $bugHash->{BugCode} and $options->{bug_code} ) {
	    $code = $bugHash->{BugCode};
	} else {
	    $code = "undefined";
	}
    } else {
	push @{$$dataHash->{cmp}{$group}}, $bugHash->{BugId};
	return;
    }

    if ($options->{only_primary}) {
	for my $location(@{$bugHash->{BugLocations}}) {
	    if ( $location->{primary} ) {
		if ( $ret > 1 ) {
		if ( exists $location->{SourceFile} and $options->{source_file} ) {
			$sourceFile = $location->{SourceFile};
		    } else {
			$sourceFile = "undefined";
		    }
		} else {
		    push @{$$dataHash->{cmp}{$group}{$code}}, $bugHash->{BugId};
		    return;
		}


		if ( $ret > 2 ) {
		    if ( exists $location->{StartLine} and $options->{start_line} ) {
			$startLine = $location->{StartLine};
		    } else {
			$startLine = "undefined";
		    }
		} else {
		    push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}}, $bugHash->{BugId};
		    return;
		}

		if ( $ret > 3 ) {
		    if ( exists $location->{EndLine} and $options->{end_line} ) {
			$endLine = $location->{EndLine};
		    } else {
			$endLine = "undefined";
		    }
		} else {
		    push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}}, $bugHash->{BugId};
		    return;
		}

		if ( $ret > 4 ) {
		    if ( exists $location->{StartColumn} and $options->{start_column} ) {
			$startCol = $location->{StartColumn};
		    } else {
			$startCol = "undefined";
		    }
		} else {
		    push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}}, $bugHash->{BugId};
		    return;
		}

		if ( $ret > 5 ) {
		    if ( exists $location->{EndColumn} and $options->{end_column} ) {
			$endCol = $location->{EndColumn};
		    } else {
			$endCol = "undefined";
		    }
		} else {
		    push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}}, $bugHash->{BugId};
		    return;
		}
	    }
	}
    }


    if ( $ret > 6 ) {
	if ( not exists $$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} ) {
	    $$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} = [];
	}
	my $secondaryHash = {};
	$secondaryHash->{BugId} = [$bugHash->{BugId}];

	if ( defined $bugHash->{CweIds} and $options->{cwe}) {
	    push @{$secondaryHash->{CweIds}}, @{$bugHash->{CweIds}};
	} else {
	    $secondaryHash->{CweIds} = [];
	}

	if ( $ret > 7 ) {
	    if ( defined $bugHash->{Methods} and $options->{methods}) {
		$secondaryHash->{Methods} = [];
		for my $method ( @{$bugHash->{Methods}} ) {
		    push @{$secondaryHash->{Methods}}, $method->{name};
		}
	    } else {
		$secondaryHash->{Methods} = [];
	    }
	} else {
	    if ( exists $$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} ) {
		for my $secondary (@{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}) {
		    my $match = 1;
		    if (@{$secondary->{CweIds}}) {
			for my $cwe ($secondary->{CweIds}) {
			    for my $datacwe (@{$secondaryHash->{CweIds}}) {
				if ( $cwe != $datacwe ) {
				   $match = 0;
				    last;
				}
			    }
			    if (not $match){
				last;
			    }
			}
		    } elsif (@{$secondaryHash->{CweIds}}) {
		        $match = 0;
		    }
		    if ( $match ) {
			push @{$secondary->{BugId}}, $bugHash->{BugId};
			return;
		    }
		}
	    }
	    push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}, $secondaryHash;
	    return;
	}

	if ( $ret > 8 ) {
	    #do nothing
	} else {
	    if ( exists $$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol} ) {
		for my $secondary (@{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}) {
		    my $match = 1;
		    if (@{$secondary->{CweIds}}) {
			for my $cwe ($secondary->{CweIds}) {
			    for my $datacwe (@{$secondaryHash->{CweIds}}) {
				if ( $cwe != $datacwe ) {
				    $match = 0;
				    last;
				}
			    }
			    if (not $match){
				last;
			    }
			}
		    } elsif ( @{$secondaryHash->{CweIds}}) {
			$match = 0;
		    }
		    if ( $match ) {
			if (@{$secondary->{Methods}}) {
			    for my $methods (@{$secondary->{Methods}}) {
				for my $datamethods (@{$secondaryHash->{Methods}}) {
				    if ( not ($methods eq $datamethods) ) {
					$match = 0;
					last;
				    }
				}
				if (not $match){
				    last;
				}
			    }
			} elsif (@{$secondaryHash->{Methods}}) {
			    $match = 0;
			}

			if ( $match ) {
			    push @{$secondary->{BugId}}, $bugHash->{BugId};
			    return;
			}
		    }
		}
	    }
	    push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}, $secondaryHash;
	    return;
	}

    } else {
	push @{$$dataHash->{cmp}{$group}{$code}{$sourceFile}{$startLine}{$endLine}{$startCol}{$endCol}}, $bugHash->{BugId};
	return;
    }


    return;
}



sub rootBugSum
{
    my ($bugSum, $data) = @_;
    $$data->{rootBugSum} = dclone $bugSum;
    return;
}



sub cmpBugSum
{
    my ($bugSum, $data) = @_;
    $$data->{cmpBugSum} = dclone $bugSum;
    return;
}



sub rootMetricSum
{
    my ($summary, $data) = @_;
    my $type;
    for my $metrSum (@{$summary->{MetricSummaries}}) {
	$type = $metrSum->{Type};
	$$data->{rootMetricSum}{$type}{count} = $metrSum->{Count};
	if (exists $metrSum->{Sum}) {
	    $$data->{rootMetricSum}{$type}{sum} = $metrSum->{Sum};
	} else {
	    $$data->{rootMetricSum}{$type}{sum} = "undefined";
	}
	if (exists $metrSum->{SumOfSquares}) {
	    $$data->{rootMetricSum}{$type}{sumofsq} = $metrSum->{SumOfSquares};
	} else {
	    $$data->{rootMetricSum}{$type}{sumofsq} = "undefined";
	}
	if (exists $metrSum->{Maximum}) {
	    $$data->{rootMetricSum}{$type}{max} = $metrSum->{Maximum};
	} else {
	    $$data->{rootMetricSum}{$type}{max} = "undefined";
	}
	if (exists $metrSum->{Minimum}) {
	    $$data->{rootMetricSum}{$type}{min} = $metrSum->{Minimum};
	} else {
	    $$data->{rootMetricSum}{$type}{min} = "undefined";
	}
	if (exists $metrSum->{Average}) {
	    $$data->{rootMetricSum}{$type}{avg} = $metrSum->{Average};
	} else {
	    $$data->{rootMetricSum}{$type}{avg} = "undefined";
	}
	if (exists $metrSum->{StandardDeviation}) {
	    $$data->{rootMetricSum}{$type}{std} = $metrSum->{StandardDeviation};
	} else {
	    $$data->{rootMetricSum}{$type}{std} = "undefined";
	}
    }
    return;
}



sub cmpMetricSum
{
    my ($summary, $data) = @_;
    my $type;
    for my $metrSum (@{$summary->{MetricSummaries}}) {
	$type = $metrSum->{Type};
	$$data->{cmpMetricSum}{$type}{count} = $metrSum->{Count};
	if (exists $metrSum->{Sum}) {
	    $$data->{cmpMetricSum}{$type}{sum} = $metrSum->{Sum};
	} else {
	    $$data->{cmpMetricSum}{$type}{sum} = "undefined";
	}
	if (exists $metrSum->{SumOfSquares}) {
	    $$data->{cmpMetricSum}{$type}{sumofsq} = $metrSum->{SumOfSquares};
	} else {
	    $$data->{cmpMetricSum}{$type}{sumofsq} = "undefined";
	}
	if (exists $metrSum->{Maximum}) {
	    $$data->{cmpMetricSum}{$type}{max} = $metrSum->{Maximum};
	} else {
	    $$data->{cmpMetricSum}{$type}{max} = "undefined";
	}
	if (exists $metrSum->{Minimum}) {
	    $$data->{cmpMetricSum}{$type}{min} = $metrSum->{Minimum};
	} else {
	    $$data->{cmpMetricSum}{$type}{min} = "undefined";
	}
	if (exists $metrSum->{Average}) {
	    $$data->{cmpMetricSum}{$type}{avg} = $metrSum->{Average};
	} else {
	    $$data->{cmpMetricSum}{$type}{avg} = "undefined";
	}
	if (exists $metrSum->{StandardDeviation}) {
	    $$data->{cmpMetricSum}{$type}{std} = $metrSum->{StandardDeviation};
	} else {
	    $$data->{cmpMetricSum}{$type}{std} = "undefined";
	}
    }
    return;
}




######################### OPTIONS AND HELP #############################################################################################

my $version = '1.0.1 (August 12, 2016)';

sub PrintUsage
{
    my ($defaults) = @_;
    my ($conf1, $conf2) = @{$defaults}{qw/ conf_file conf_file2 /};
    my $progname = $0;

    $progname =~ s/.*[\\\/]//;

    # the message below should use spaces not tabs, so it formats correctly
    # if the user has tab stops set to something other than 8.
    print STDERR <<EOF;
Usage: $progname [options] <filepath> <filepath>

A program to determine differences between two SCARF files.

options:
    --help               -h    print this message
    --version            -v    print version
    --all                -a    enable all comparisons
    --full_bug           -fb   enable all bugs comparisons
    --bug_code           -c    enable/disable bug_code comparison
    --bug_group          -g    enable/disable bug_group comparison
    --source_file        -f    enable/disable source_file comparison
    --start_line         -sl   enable/disable start_line comparison
    --end_line           -el   enable/disable end_line comparison
    --start_column       -sc   enable/disable start_column comparison
    --end_column         -ec   enable/disable end_column comparison
    --methods            -m    enable/disable  comparison
    --cweid              -cwe  enable/disable bug_code comparison
    --metric                   enable/disable metric diff functionality
    --summary            -s    enable/disable only reading summary for diff information
    --json               -j    enable JSON parsing instead of XML
EOF
#    --bug_message                -bm enable/disable bug_code comparison
#    --only_primary               -p enable/disable bug_code comparison
#EOF
}



# PrintVersion - Print the version of the program
#
sub PrintVersion
{
    my $progname = $0;

    $progname =~ s/.*(\\\/)//;
    print "$progname version $version\n";
}



# ProcessOptions - Process the options and handle help and version
#
# exits with 0 status if --help or --version is supplied
#       with 1 status if an invalid options is supplied
#
# returns a reference to a hash containing the option
#
sub ProcessOptions
{
    my %optionDefaults = (
		help		=> 0,
		version		=> 0,
		all		=> 0,
		bug_code	=> 1,
		bug_group	=> 1,
		source_file	=> 1,
		start_line	=> 1,
		end_line	=> 0,
		start_column	=> 0,
		end_column	=> 0,
		methods		=> 0,
		cwe		=> 0,
#                bug_message	=> 0,
		only_primary	=> 1,
		summary		=> 0,
		metric		=> 0,
		verbosity	=> 0,
		json		=> 0,
		full_bug	=> 0
                );

    # for options that contain a '-', make the first value be the
    # same string with '-' changed to '_', so quoting is not required
    # to access the key in the hash $option{input_file} instead of
    # $option{'input-file'}
    my @options = (
                "help|h!",
                "version|v!",
		"all|a",
		"bug_code|bug-code|bugcode|code|c!",
		"bug_group|bug-group|buggroup|group|g!",
		"source_file|source-file|sourcefile|file|f!",
		"start_line|start-line|startline|sl!",
		"end_line|end-line|endline|el!",
		"start_column|start-column|startcolumn|start_col|start-col|startcol|sc!",
		"end_column|end-column|endcolumn|end_col|end-col|endcol|ec!",
		"methods|method|m!",
		"cwe|cweid|cweids!",
#		"bug_message|bug-message|bugmessage|message|bm!",
		"only_primary|onlyprimary|primary|p!",
		"summary|Summary|sum|s!",
		"metric|metrics!",
		"json|JSON|j!",
		"full_bug|full-bug|full|bug|fb"
                );

    # Configure file options, will be read in this order
    my @confFileOptions = qw/ conf_file conf_file2 /;

    Getopt::Long::Configure(qw/require_order no_ignore_case no_auto_abbrev/);
    my %getoptOptions;
    my $ok = GetOptions(\%getoptOptions, @options);

    my %options = %optionDefaults;
    my %optSet;
    while (my ($k, $v) = each %getoptOptions)  {
        $options{$k} = $v;
        $optSet{$k} = 1;
    }
    
    if ($options{json})  {
	print STDERR "ERROR:  --json is not supported.\n";
	$ok = 0;
    }

    if (@ARGV != 2 && !$options{help} && !$options{version})  {
	print STDERR "ERROR:  Exactly two files must be specified to compare.\n";
	$ok = 0;
    }

    if (!$ok || $options{help})  {
        PrintUsage(\%optionDefaults);
        exit !$ok;
    }

    if ($ok && $options{version})  {
        PrintVersion();
        exit 0;
    }
    return \%options;
}



####################################### Print Output #############################
sub printNew
{
    my ( $newElements, $ret ) = @_;
    my $out;
    my $count;
    if ( $ret == 0 ) {
	for my $group ( keys %{$newElements} ) {
	    $count = $newElements->{$group};
	    print "+ $count BugInstances categorized by BugGroup: $group\n";
	}
    } elsif ( $ret == 1 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		$count = $newElements->{$group}{$code};
		print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code\n";
	    }
	}
    } elsif ( $ret == 2 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    $count = $newElements->{$group}{$code}{$source};
		    print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source\n";
		}
	    }
	}
    } elsif ( $ret == 3 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$newElements->{$group}{$code}{$source}} ) {
			$count = $newElements->{$group}{$code}{$source}{$startLine};
			print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine\n";
		    }
		}
	    }
	}
    } elsif ( $ret == 4 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$newElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$newElements->{$group}{$code}{$source}{$startLine}} ) {
			    $count = $newElements->{$group}{$code}{$source}{$startLine}{$endLine};
			    print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine\n";
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 5 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$newElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$newElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				$count = $newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol};
				print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol\n";
			    }
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 6 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$newElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$newElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				for my $endCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}} ) {
				    $count = $newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}{$endCol};
				    print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol, EndColumn: $endCol\n";
				}
			    }
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 7 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$newElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$newElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				for my $endCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}} ) {
				    for my $secondary (@{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}{$endCol}}) {
					$count = $secondary->{BugId};
					print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol, EndColumn: $endCol, ",
						"CweIds: @{$secondary->{CweIds}}\n";
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 8 ) {
	for my $group ( keys %{$newElements} ) {
	    for my $code ( keys %{$newElements->{$group}} ) {
		for my $source ( keys %{$newElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$newElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$newElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				for my $endCol ( keys %{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}} ) {
				    for my $secondary (@{$newElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}{$endCol}}) {
					$count = $secondary->{BugId};
					print "+ $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol, EndColumn: $endCol, ",
						"CweIds: @{$secondary->{CweIds}}, Methods: @{$secondary->{Methods}}\n";
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}



sub printRemoved
{
    my ( $remElements, $ret ) = @_;
    my $out;
    my $count;
    if ( $ret == 0 ) {
	for my $group ( keys %{$remElements} ) {
	    $count = $remElements->{$group};
	    print "- $count BugInstances categorized by BugGroup: $group\n";
	}
    } elsif ( $ret == 1 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		$count = $remElements->{$group}{$code};
		print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code\n";
	    }
	}
    } elsif ( $ret == 2 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    $count = $remElements->{$group}{$code}{$source};
		    print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source\n";
		}
	    }
	}
    } elsif ( $ret == 3 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$remElements->{$group}{$code}{$source}} ) {
			$count = $remElements->{$group}{$code}{$source}{$startLine};
			print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine\n";
		    }
		}
	    }
	}
    } elsif ( $ret == 4 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$remElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$remElements->{$group}{$code}{$source}{$startLine}} ) {
			    $count = $remElements->{$group}{$code}{$source}{$startLine}{$endLine};
			    print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine\n";
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 5 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$remElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$remElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				$count = $remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol};
				print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol\n";
			    }
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 6 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$remElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$remElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				for my $endCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}} ) {
				    $count = $remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}{$endCol};
				    print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol, EndColumn: $endCol\n";
				}
			    }
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 7 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$remElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$remElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				for my $endCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}} ) {
				    for my $secondary (@{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}{$endCol}}) {
					$count = $secondary->{BugId};
					print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol, EndColumn: $endCol, ",
						"CweIds: @{$secondary->{CweIds}}\n";
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    } elsif ( $ret == 8 ) {
	for my $group ( keys %{$remElements} ) {
	    for my $code ( keys %{$remElements->{$group}} ) {
		for my $source ( keys %{$remElements->{$group}{$code}} ) {
		    for my $startLine ( keys %{$remElements->{$group}{$code}{$source}} ) {
			for my $endLine ( keys %{$remElements->{$group}{$code}{$source}{$startLine}} ) {
			    for my $startCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}} ) {
				for my $endCol ( keys %{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}} ) {
				    for my $secondary (@{$remElements->{$group}{$code}{$source}{$startLine}{$endLine}{$startCol}{$endCol}}) {
					$count = $secondary->{BugId};
					print "- $count BugInstances categorized by BugGroup: $group, BugCode: $code, SourceFile: $source, StartLine: $startLine, EndLine: $endLine, StartColumn: $startCol, EndColumn: $endCol, ",
						"CweIds: @{$secondary->{CweIds}}, Methods: @{$secondary->{Methods}}\n";
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
}



sub printNewMetrics
{
    my ($newElts) = @_;
    my $count;
    foreach my $type (keys %{$newElts}) {
	foreach my $source (keys %{$newElts->{$type}}) {
	    foreach my $class (keys %{$newElts->{$type}{$source}}) {
		foreach my $method (keys %{$newElts->{$type}{$source}{$class}}) {
		    foreach my $value (keys %{$newElts->{$type}{$source}{$class}{$method}}) {
			$count = $newElts->{$type}{$source}{$class}{$method}{$value};
			print "+ $count Metricss categorized by Type: $type, SourceFile: $source, ClassName: $class, MethodName: $method and Value: $value\n";
		    }
		}
	    }
	}
    }
}



sub printRemovedMetrics
{
    my ($remElts) = @_;
    my $count;
    foreach my $type (keys %{$remElts}) {
	foreach my $source (keys %{$remElts->{$type}}) {
	    foreach my $class (keys %{$remElts->{$type}{$source}}) {
		foreach my $method (keys %{$remElts->{$type}{$source}{$class}}) {
		    foreach my $value (keys %{$remElts->{$type}{$source}{$class}{$method}}) {
			$count = $remElts->{$type}{$source}{$class}{$method}{$value};
			print "- $count Metricss categorized by Type: $type, SourceFile: $source, ClassName: $class, MethodName: $method and Value: $value\n";
		    }
		}
	    }
	}
    }
}



sub printHeader
{
    my ($root, $cmp) = @_;
    print "--- $root\n";
    print "+++ $cmp\n";
}



sub printBugSumDif
{
    my ($rootSum, $cmpSum) = @_;
    my $foundGroup = 0 ;
    foreach my $rootGroup ( keys %{$rootSum} ) {
	foreach my $cmpGroup ( keys %{$cmpSum} ) {
	    if ( $rootGroup eq $cmpGroup ) {
		$foundGroup = 1;
		my $foundCode = 0;
		foreach my $rootCode ( keys %{$rootSum->{$rootGroup}} ) {
		    foreach my $cmpCode ( keys %{$cmpSum->{$cmpGroup}} ) {
			if ( $cmpCode eq $rootCode ) {
			    $foundCode = 1;
			    my $bytes = $rootSum->{$rootGroup}{$rootCode}{bytes} - $cmpSum->{$rootGroup}{$rootCode}{bytes};
			    my $count = $rootSum->{$rootGroup}{$rootCode}{count} - $cmpSum->{$rootGroup}{$rootCode}{count};
			    if ( $count < 0 ) {
				my $abscount = abs $count;
				my $absbytes = abs $bytes;
				print "+ $abscount BugInstances categorized by BugGroup: $rootGroup and BugCode: $rootCode accounted for $absbytes additional bytes\n";
			    } elsif ( $count > 0 ) {
				my $abscount = abs $count;
				my $absbytes = abs $bytes;
				print "- $abscount BugInstances categorized by BugGroup: $rootGroup and BugCode: $rootCode accounted for $absbytes removed bytes\n";
			    }
			    delete $cmpSum->{$rootGroup}{$rootCode};
			    last;
			} else {
			    next;
			}
		    }
		    if ( $foundCode == 0 ) {
			print "- $rootSum->{$rootGroup}{$rootCode}{count} BugInstances categorized by BugGroup: $rootGroup and BugCode: $rootCode accounted for $rootSum->{$rootGroup}{$rootCode}{bytes} removed bytes\n";
		    }
		}
		last;
	    } else {
		next;
	    }
	}
	if ( $foundGroup == 0 ) {
	    foreach my $rootCode ( keys %{$rootSum->{$rootGroup}} ) {
		print "- $rootSum->{$rootGroup}{$rootCode}{count} BugInstances categorized by BugGroup: $rootGroup and BugCode: $rootCode accounted for $rootSum->{$rootGroup}{$rootCode}{bytes} removed bytes\n";
	    }
	}
    }
    foreach my $cmpGroup ( keys %{$cmpSum} ) {
	foreach my $cmpCode ( keys %{$cmpSum->{$cmpGroup}} ) {
	    print "+ $cmpSum->{$cmpGroup}{$cmpCode}{count} BugInstances categorized by BugGroup: $cmpGroup and BugCode: $cmpCode accounted for $cmpSum->{$cmpGroup}{$cmpCode}{bytes} removed bytes\n";
	}
    }
    return;
}



sub printMetricSumDif
{
    my ($rootSum, $cmpSum) = @_;
    my $cmpCount;
    my $rootCount;
    my $difCount;
    my $printCount;
    foreach my $type (keys %{$rootSum}){
	$rootCount = $rootSum->{$type}{count};
	if (exists $cmpSum->{$type}) {
	    $cmpCount = $cmpSum->{$type}{count};
	} else {
	    $cmpCount = 0;
	}
	$difCount = $rootCount - $cmpCount;
	$printCount  = abs $difCount;
	if ($difCount > 0) {
	    print "- $printCount Metrics categorized by Type: $type "
	} elsif ($difCount < 0) {
	    print "+ $printCount Metrics categorized by Type: $type "
	}
	delete $cmpSum->{$type};
    }
    foreach my $type (keys %{$cmpSum}){
	print "+ $cmpSum->{$type}{count} Metrics categorized by Type: $type "
    }
}


#################### MAIN SCRIPT ##########################################################################################################

#Options
my $options = ProcessOptions();
if ( $options->{all} ) {
    $options->{bug_code} = 1;
    $options->{bug_group} = 1;
    $options->{source_file} = 1;
    $options->{start_line} = 1;
    $options->{end_line} = 1;
    $options->{start_column} = 1;
    $options->{end_column} = 1;
    $options->{methods} = 1;
    $options->{cwe} = 1;
    $options->{metric} = 1;
#    $options->{bug_message} = 1;
#    $options->{only_primary} = 0;
} elsif ($options->{summary}) {
    $options->{bug_code} = 0;
    $options->{bug_group} = 0;
    $options->{source_file} = 0;
    $options->{start_line} = 0;
    $options->{end_line} = 0;
    $options->{start_column} = 0;
    $options->{end_column} = 0;
    $options->{methods} = 0;
    $options->{cwe} = 0;
    $options->{metric} = 0;
#    $options->{bug_message} = 0;
#    $options->{only_primary} = 0;
} elsif ($options->{fullBug}) {
    $options->{bug_code} = 1;
    $options->{bug_group} = 1;
    $options->{source_file} = 1;
    $options->{start_line} = 1;
    $options->{end_line} = 1;
    $options->{start_column} = 1;
    $options->{end_column} = 1;
    $options->{methods} = 1;
    $options->{cwe} = 1;
}

my ($rootFile, $cmpFile) = @ARGV;

#Initialize data structure
my $data = {};
$data->{options} = $options;
$data->{root} = {};
$data->{cmp} = {};
$data->{rootBugSum} = {};
$data->{cmpBugSum} = {};
$data->{rootMetricSum} = {};
$data->{cmpMetricSum} = {};
$data->{rootMetrics} = {};
$data->{cmpMetrics} = {};
$data->{new} = {};
$data->{removed} = {};
$data->{newMetrics} = {};
$data->{removedMetrics} = {};
#$data->{matchesInRoot} = {};
#$data->{matches} = {};

#Find structure
if ($options->{methods}) {
    $data->{ret} = 8;
} elsif ($options->{cwe}) {
    $data->{ret} = 7;
} elsif ($options->{end_column}) {
    $data->{ret} = 6;
} elsif ($options->{start_column}) {
    $data->{ret} = 5;
} elsif ($options->{end_line}) {
    $data->{ret} = 4;
} elsif ($options->{start_line}) {
    $data->{ret} = 3;
} elsif ($options->{source_file}) {
    $data->{ret} = 2;
} elsif ($options->{bug_code}) {
    $data->{ret} = 1;
} elsif ($options->{bug_group}) {
    $data->{ret} = 0;
} else {
    $data->{ret} = -1; #no bug checks set
}

my ($rootReader, $cmpReader);
if (not $options->{json}) {
    $rootReader = new ScarfXmlReader($rootFile);
    $cmpReader =  new ScarfXmlReader($cmpFile);
} else {
    die "json reader not supported.";
#    $rootReader = new ScarfJSONReader($rootFile);
#    $cmpReader =  new ScarfJSONReader($cmpFile);
}
if ($data->{ret} >= 0){
    $cmpReader->SetBugCallback(\&cmpBug);
    $rootReader->SetBugCallback(\&rootBug);
}
if ($options->{metric}) {
    $cmpReader->SetMetricCallback(\&cmpMetric);
    $rootReader->SetMetricCallback(\&rootMetric);
}
if ($options->{summary}) {
    $rootReader->SetMetricSummaryCallback(\&rootMetrSum);
    $rootReader->SetBugSummaryCallback(\&rootBugSum);
    $rootReader->SetMetricSummaryCallback(\&cmpMetrSum);
    $cmpReader->SetBugSummaryCallback(\&cmpBugSum);
}
$rootReader->SetCallbackData(\$data);
$cmpReader->SetCallbackData(\$data);

###### store data #######
$rootReader->Parse;
$cmpReader->Parse;

###### find diff ########
if ($data->{ret} > 0){
    diff(dclone $data->{root}, dclone $data->{cmp}, $data->{ret}, $data);
}
if ($options->{metric}) {
    diffMetric(dclone $data->{rootMetrics}, dclone $data->{cmpMetrics}, $data);
}

##### print diff #########
printHeader ($rootFile, $cmpFile);
if ($data->{ret} > 0){
    printNew ($data->{new}, $data->{ret});
    printRemoved ($data->{removed}, $data->{ret});
}
if ($options->{metric}) {
    printNewMetrics ($data->{newMetrics}, $data->{ret});
    printRemovedMetrics ($data->{removedMetrics}, $data->{ret});
}
if ($options->{summary}) {
    printBugSumDif(dclone $data->{rootBugSum}, dclone $data->{cmpBugSum});
    printMetricSumDif(dclone $data->{rootMetricSum}, dclone $data->{cmpMetricSum});
}




####### debug ############

#print ("$data->{ret}\n");

#print "ROOT\n";
#print Dumper($data->{root});
#print "CMP\n";
#print Dumper($data->{cmp});

#print ("NEW\n");
#print Dumper($data->{new});
#print ("REMOVED\n");
#print Dumper($data->{removed});
