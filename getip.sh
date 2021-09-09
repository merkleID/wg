classA()
	{
	ip a sh dev wg701 | grep inet | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | awk -F "." '{print $1}'
}

classB()
        {
        ip a sh dev wg701 | grep inet | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | awk -F "." '{print $2}'
}

classC()
        {
        ip a sh dev wg701 | grep inet | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | awk -F "." '{print $3}'
}

classD()
        {
        ip a sh dev wg701 | grep inet | awk -F " " '{print $2}' | awk -F "/" '{print $1}' | awk -F "." '{print $4}'
}

A=$(classA)
B=$(classB)
C=$(classC)
D=$(classD)

echo $A
echo $B
echo $C
echo $D
