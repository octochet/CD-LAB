switch(a)
{
	case 0*1: {a=b+c;break;}
	case 1*8+7: {p=q+r;break;}
	default: {
		switch(b) {
			case 0: {a=b+c;break;}
			case 1: {p=q+r;break;}
			default: {a=b+c;}
		}
	}
}